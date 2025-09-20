pub mod client_session_delegate;
pub mod init_request;
pub mod list_chats_request;
pub mod logout_request;
pub mod oidc_auth_request;
pub mod oidc_finish_request;
pub mod process_sync_response_request;
pub mod refresh_token_request;

use std::{io::ErrorKind, path::PathBuf, sync::Arc};

use matrix_sdk::Client as SdkClient;
use matrix_sdk_rinf::client::Client;
use messages::{actor::Actor, prelude::Address};
use tokio::task::JoinSet;
use rinf::debug_print;

use crate::{
    actors::matrix::client_session_delegate::ClientSessionDelegateImplementation,
    extensions::easy_listener::EasyListener,
    signals::{
        MatrixInitRequest, MatrixListChatsRequest, MatrixLogoutRequest,
        MatrixOidcAuthFinishRequest, MatrixOidcAuthRequest, MatrixProcessSyncResponseRequest,
        MatrixRefreshTokenRequest, init_client_error::InitClientError,
    },
};

pub struct Matrix {
    self_addr: Address<Self>,
    client: Option<Client>,
    owned_tasks: JoinSet<()>,
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
        debug_print!("# application folder: {}", &client0_dir.to_str().unwrap());
        client0_dir.push("./client0");

        self.client.take();

        if let Err(err) = tokio::fs::create_dir(&client0_dir).await
            && err.kind() != ErrorKind::AlreadyExists
        {
            return Err(InitClientError::FailedToCreateStorageFolder(err));
        };

        let sdk_client = SdkClient::builder()
            .server_name_or_homeserver_url(&homeserver_url)
            .sqlite_store(&client0_dir, None)
            .build()
            .await
            .map_err(InitClientError::SdkClientBuildError)?;

        let session_delegate = ClientSessionDelegateImplementation::new(application_support_directory.clone());
        let client = Client::new(
            sdk_client,
            true,
            Some(Arc::new(session_delegate)),
            Some(client0_dir.clone()),
        )
        .await
        .map_err(InitClientError::ClientBuildError)?;

        self.client = Some(client);
        Ok(())
    }

    pub async fn clean_storage(&self) -> Result<(), ()> {
        let dir = self.application_support_directory.clone().ok_or(())?;
        debug_print!("# clean_storage: removing {dir:?}");

        let mut entries = tokio::fs::read_dir(dir).await.map_err(|_| ())?;
        while let Ok(Some(entry)) = entries.next_entry().await {
            let path = entry.path();
            debug_print!("# clean_storage: removing {path:?}");
            let _ = tokio::fs::remove_dir_all(path).await;
        }

        Ok(())
    }

    pub fn emit_logout_request(&mut self) {
        let mut addr = self.self_addr.clone();
        self.owned_tasks.spawn(async move {
            let request = MatrixLogoutRequest {};
            let _ = addr.notify(request).await;
        });
    }
}
