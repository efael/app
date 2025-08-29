pub mod init_request;
pub mod oidc_auth_request;
pub mod oidc_finish_request;

use std::{io::ErrorKind, path::PathBuf};

use matrix_sdk::{Client, ruma::exports::serde_json};
use messages::{actor::Actor, prelude::Address};
use tokio::task::JoinSet;

use crate::{
    extensions::easy_listener::EasyListener,
    signals::{
        MatrixInitRequest, MatrixOidcAuthFinishRequest, MatrixOidcAuthRequest,
        full_session::FullSession, init_client_error::InitClientError, logout_error::LogoutError,
        save_session_error::SaveSessionError,
    },
};

pub struct Matrix {
    client: Option<Client>,
    owned_tasks: JoinSet<()>,
    self_addr: Address<Self>,
    application_support_directory: Option<PathBuf>,
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
    pub fn new(self_addr: Address<Self>) -> Self {
        let owned_tasks = JoinSet::new();

        let mut actor = Self {
            client: None,
            owned_tasks,
            self_addr,
            application_support_directory: None,
        };

        actor.listen_to::<MatrixInitRequest>();
        actor.listen_to::<MatrixOidcAuthRequest>();
        actor.listen_to::<MatrixOidcAuthFinishRequest>();

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

        if let Ok(ref session) = tokio::fs::read_to_string(&client0_session).await
            && let Ok(FullSession {
                user_session,
                sync_token: _,
            }) = serde_json::from_str(session)
        {
            let _ = client.restore_session(user_session).await;
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

    pub async fn save_session(&mut self) -> Result<(), SaveSessionError> {
        if let Some(ref client) = self.client
            && let Some(user_session) = client.matrix_auth().session()
            && let Some(ref application_support_directory) = self.application_support_directory
        {
            let session = FullSession {
                user_session,
                sync_token: None,
            };

            let session = serde_json::to_string(&session).map_err(SaveSessionError::Serialize)?;

            let mut client0_session = application_support_directory.clone();
            client0_session.push("./client0/session.json");

            tokio::fs::write(client0_session, session)
                .await
                .map_err(SaveSessionError::Save)?;
        }

        Ok(())
    }
}
