pub mod init_request;
pub mod list_chats_request;
pub mod logout_request;
pub mod oidc_auth_request;
pub mod oidc_finish_request;
pub mod refresh_token_request;
pub mod sas_confirm_request;
pub mod session_verification_request;
// pub mod sync_background_request;
pub mod refresh_session_request;
pub mod session_callbacks;
pub mod sync_completed_request;
pub mod sync_new;
pub mod sync_once_request;

use std::{io::ErrorKind, path::PathBuf, sync::Arc};

use matrix_sdk::{
    AuthSession, Client as SdkClient,
    crypto::DecryptionSettings,
    encryption::{BackupDownloadStrategy, EncryptionSettings},
    sliding_sync::VersionBuilder,
};
use messages::{
    actor::Actor,
    prelude::{Address, Notifiable},
};
use rinf::DartSignal;
use tokio::task::JoinSet;

use crate::{
    actors::matrix::session_callbacks::{reload_session_callback, save_session_callback},
    extensions::easy_listener::EasyListener,
    matrix::{room_list::RoomList, session::Session},
    signals::{
        MatrixInitRequest, MatrixListChatsRequest, MatrixLogoutRequest,
        MatrixOidcAuthFinishRequest, MatrixOidcAuthRequest, MatrixRefreshSessionRequest,
        MatrixRefreshTokenRequest, MatrixSASConfirmRequest, MatrixSessionVerificationRequest,
        MatrixSyncBackgroundRequest, MatrixSyncCompleted, MatrixSyncOnceRequest,
        init_client_error::InitClientError,
    },
};

#[derive(Debug)]
pub struct Matrix {
    self_addr: Address<Self>,
    client: Option<SdkClient>,
    owned_tasks: JoinSet<()>,
    application_support_directory: Option<PathBuf>,
    session: Option<Session>,
    room_list: Arc<RoomList>,
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
            room_list: Arc::new(RoomList::default()),
        };

        actor.listen_to_handler::<MatrixInitRequest>();
        actor.listen_to_notification::<MatrixOidcAuthRequest>();
        actor.listen_to_notification::<MatrixOidcAuthFinishRequest>();
        actor.listen_to_notification::<MatrixListChatsRequest>();
        actor.listen_to_notification::<MatrixLogoutRequest>();
        actor.listen_to_notification::<MatrixRefreshTokenRequest>();
        actor.listen_to_notification::<MatrixSyncBackgroundRequest>();
        actor.listen_to_notification::<MatrixSyncOnceRequest>();
        actor.listen_to_notification::<MatrixSessionVerificationRequest>();
        actor.listen_to_notification::<MatrixSASConfirmRequest>();
        actor.listen_to_notification::<MatrixSyncCompleted>();
        actor.listen_to_notification::<MatrixRefreshSessionRequest>();

        actor
    }

    #[tracing::instrument(skip(self))]
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

        let sdk_client = SdkClient::builder()
            .server_name_or_homeserver_url(&homeserver_url)
            .sqlite_store(&client0_dir, None)
            .sliding_sync_version_builder(VersionBuilder::DiscoverNative)
            .with_decryption_settings(DecryptionSettings {
                sender_device_trust_requirement: matrix_sdk::crypto::TrustRequirement::Untrusted,
            })
            .with_encryption_settings(EncryptionSettings {
                auto_enable_cross_signing: true,
                backup_download_strategy: BackupDownloadStrategy::OneShot,
                auto_enable_backups: true,
            })
            .with_enable_share_history_on_invite(true)
            .handle_refresh_tokens()
            .build()
            .await
            .map_err(InitClientError::SdkClientBuildError)?;

        tracing::trace!("client initialized");

        sdk_client
            .set_session_callbacks(
                {
                    let session_path = self.session_path();
                    let address = self.get_address();

                    reload_session_callback(session_path, address)
                },
                {
                    let session_path = self.session_path();
                    let address = self.get_address();

                    save_session_callback(session_path, address)
                },
            )
            .expect("failed to set session callbacks");

        let session_path = self.session_path();

        if let Ok(session) = Session::load_from_disk(session_path) {
            sdk_client
                .restore_session(AuthSession::from(&session))
                .await
                .expect("failed to restore session");

            tracing::trace!("client session was successfully restored");
            self.session = Some(session.clone());

            self.emit(MatrixSyncOnceRequest {
                sync_token: session.sync_token,
            });
        };

        self.client = Some(sdk_client);
        Ok(())
    }

    #[tracing::instrument(skip(self))]
    pub async fn clean_storage(&self) -> Result<(), ()> {
        let dir = self.application_support_directory.clone().ok_or(())?;
        tracing::trace!("removing {dir:?}");

        let mut entries = tokio::fs::read_dir(dir).await.map_err(|_| ())?;
        while let Ok(Some(entry)) = entries.next_entry().await {
            let path = entry.path();
            tracing::trace!("removing {path:?}");

            let _ = tokio::fs::remove_dir_all(&path).await;
            let _ = tokio::fs::remove_file(&path).await;
        }

        Ok(())
    }

    #[tracing::instrument(skip(self, request))]
    pub fn emit<Signal>(&mut self, request: Signal)
    where
        Self: Notifiable<Signal>,
        Signal: DartSignal + Send + 'static,
    {
        tracing::trace!("emitting {}", std::any::type_name_of_val(&request));
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
