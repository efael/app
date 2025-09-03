pub mod init_request;
pub mod list_chats_request;
pub mod logout_request;
pub mod oidc_auth_request;
pub mod oidc_finish_request;
pub mod process_sync_response_request;
pub mod refresh_token_request;

use std::{io::ErrorKind, path::PathBuf};

use matrix_sdk::{Client, ruma::exports::serde_json};
use messages::{actor::Actor, prelude::Address};
use tokio::task::JoinSet;

use crate::{
    actors::matrix_sync::MatrixSync,
    extensions::easy_listener::EasyListener,
    signals::{
        MatrixInitRequest, MatrixListChatsRequest, MatrixLogoutRequest,
        MatrixOidcAuthFinishRequest, MatrixOidcAuthRequest, MatrixProcessSyncResponseRequest,
        MatrixRefreshTokenRequest, MatrixSyncRequest, full_session::FullSession,
        init_client_error::InitClientError, logout_error::LogoutError,
        save_session_error::SaveSessionError,
    },
};

pub struct Matrix {
    self_addr: Address<Self>,
    client: Option<Client>,
    owned_tasks: JoinSet<()>,
    application_support_directory: Option<PathBuf>,
    matrix_sync_addr: Address<MatrixSync>,
}

impl Actor for Matrix {}

impl EasyListener for Matrix {
    fn spawn_listener<F>(&mut self, task: F)
    where
        F: Future<Output = ()>,
        F: Send + 'static,
    {
        self.owned_tasks.spawn(task);
    }

    fn get_address(&self) -> Address<Self> {
        self.self_addr.clone()
    }
}

impl Matrix {
    pub fn new(self_addr: Address<Self>, matrix_sync_addr: Address<MatrixSync>) -> Self {
        let owned_tasks = JoinSet::new();

        let mut actor = Self {
            client: None,
            owned_tasks,
            self_addr,
            application_support_directory: None,
            matrix_sync_addr,
        };

        actor.listen_to::<MatrixInitRequest>();
        actor.listen_to::<MatrixOidcAuthRequest>();
        actor.listen_to::<MatrixOidcAuthFinishRequest>();
        actor.listen_to::<MatrixListChatsRequest>();
        actor.listen_to::<MatrixLogoutRequest>();
        actor.listen_to::<MatrixRefreshTokenRequest>();
        actor.listen_to::<MatrixProcessSyncResponseRequest>();

        actor
    }

    pub async fn init_client(&mut self, homeserver_url: String) -> Result<(), InitClientError> {
        let application_support_directory = self.application_support_directory.as_ref().ok_or(
            InitClientError::FailedToCreateStorageFolder(ErrorKind::NotFound.into()),
        )?;

        let mut client0_dir = application_support_directory.clone();
        client0_dir.push("./client0");

        self.client.take();

        if let Err(err) = tokio::fs::create_dir(&client0_dir).await
            && err.kind() != ErrorKind::AlreadyExists
        {
            return Err(InitClientError::FailedToCreateStorageFolder(err));
        };

        let client = Client::builder()
            .server_name_or_homeserver_url(homeserver_url)
            .sqlite_store(&client0_dir, None)
            .build()
            .await
            .map_err(InitClientError::ClientBuildError)?;

        let mut client0_session = client0_dir.clone();
        client0_session.push("./session.json");

        if let Some(FullSession {
            user_session,
            sync_token,
        }) = self.get_session().await
        {
            let _ = client.restore_session(user_session).await;

            if client.auth_api().is_some() {
                self.emit_sync_request(MatrixSyncRequest::Init {
                    client: client.clone(),
                    sync_token,
                });
            }
        }

        self.client = Some(client);

        Ok(())
    }

    pub async fn logout(&mut self) -> Result<(), LogoutError> {
        let client = match self.client.take() {
            Some(client) => client,
            None => {
                return Err(LogoutError::ClientNotInitialized);
            }
        };

        let application_support_directory = self.application_support_directory.as_ref().ok_or(
            InitClientError::FailedToCreateStorageFolder(ErrorKind::NotFound.into()),
        )?;

        let mut client0_dir = application_support_directory.clone();
        client0_dir.push("./client0");

        let homeserver_url = client.homeserver();

        let _ = client.logout().await;
        drop(client);
        self.client = None;

        tokio::fs::remove_dir_all(client0_dir)
            .await
            .map_err(LogoutError::FailedToRemoveDirectory)?;

        return self
            .init_client(homeserver_url.into())
            .await
            .map_err(|err| err.into());
    }

    pub async fn get_session(&self) -> Option<FullSession> {
        let application_support_directory = self.application_support_directory.as_ref()?;
        let mut client0_session = application_support_directory.clone();
        client0_session.push("./client0/session.json");
        let session = tokio::fs::read_to_string(&client0_session).await.ok()?;
        serde_json::from_str(&session).ok()
    }

    pub async fn save_session(
        &mut self,
        sync_token: Option<String>,
    ) -> Result<Option<FullSession>, SaveSessionError> {
        if let Some(ref client) = self.client
            && let Some(user_session) = client.matrix_auth().session()
            && let Some(ref application_support_directory) = self.application_support_directory
        {
            let session = FullSession {
                user_session,
                sync_token,
            };

            let session_str =
                serde_json::to_string(&session).map_err(SaveSessionError::Serialize)?;

            let mut client0_session = application_support_directory.clone();
            client0_session.push("./client0/session.json");

            tokio::fs::write(client0_session, session_str)
                .await
                .map_err(SaveSessionError::Save)?;

            return Ok(Some(session));
        }

        Ok(None)
    }

    pub fn emit_logout_request(&mut self) {
        let mut addr = self.self_addr.clone();
        self.owned_tasks.spawn(async move {
            let request = MatrixLogoutRequest {};
            let _ = addr.notify(request).await;
        });
    }

    pub fn emit_sync_request(&mut self, request: MatrixSyncRequest) {
        let mut addr = self.matrix_sync_addr.clone();
        self.owned_tasks.spawn(async move {
            let _ = addr.notify(request).await;
        });
    }
}
