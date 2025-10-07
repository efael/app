pub mod client_session_delegate;
pub mod session_verification_delegate;
pub mod init_request;
pub mod list_chats_request;
pub mod logout_request;
pub mod oidc_auth_request;
pub mod oidc_finish_request;
pub mod refresh_token_request;
pub mod sync_service_request;
pub mod session_verification_request;
pub mod sas_confirm_request;

use std::{io::ErrorKind, path::PathBuf};

use matrix_sdk::Client as SdkClient;
use messages::{
    actor::Actor,
    prelude::{Address, Notifiable},
};
use rinf::{DartSignal, debug_print};
use tokio::task::JoinSet;

use crate::{
    extensions::easy_listener::EasyListener, matrix::session::Session, signals::{
        init_client_error::InitClientError, MatrixInitRequest, MatrixListChatsRequest, MatrixLogoutRequest, MatrixOidcAuthFinishRequest, MatrixOidcAuthRequest, MatrixRefreshTokenRequest, MatrixSASConfirmRequest, MatrixSessionVerificationRequest, MatrixSyncServiceRequest
    }
};

pub struct Matrix {
    self_addr: Address<Self>,
    client: Option<SdkClient>,
    owned_tasks: JoinSet<()>,
    application_support_directory: Option<PathBuf>,
    session: Option<Session>,

    // sync_service: Option<Arc<SyncService>>,
    // room_service: Option<Arc<RoomListService>>,
    // verification_controller: Option<Arc<SessionVerificationController>>
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
            session: None,
        };

        actor.listen_to::<MatrixInitRequest>();
        actor.listen_to::<MatrixOidcAuthRequest>();
        actor.listen_to::<MatrixOidcAuthFinishRequest>();
        actor.listen_to::<MatrixListChatsRequest>();
        actor.listen_to::<MatrixLogoutRequest>();
        actor.listen_to::<MatrixRefreshTokenRequest>();
        actor.listen_to::<MatrixSyncServiceRequest>();
        actor.listen_to::<MatrixSessionVerificationRequest>();
        actor.listen_to::<MatrixSASConfirmRequest>();

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

        self.client = Some(sdk_client);
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

    pub fn emit<Signal>(&mut self, request: Signal)
    where
        Self: Notifiable<Signal>,
        Signal: DartSignal + Send + 'static,
    {
        let mut addr = self.self_addr.clone();
        self.owned_tasks.spawn(async move {
            let _ = addr.notify(request).await;
        });
    }
}

impl Matrix {
    pub fn session_path(&self) -> PathBuf {
        let mut dir = self.application_support_directory.clone().unwrap().clone();

        dir.push("./session.json");
        dir
    }
}