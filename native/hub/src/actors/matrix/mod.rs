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
use rinf::{DartSignal, debug_print};
use tokio::task::JoinSet;

use crate::{
    extensions::{easy_listener::EasyListener, emitter::Emitter},
    matrix::{room_list::RoomList, session::Session},
    signals::{
        MatrixInitRequest, MatrixListChatsRequest, MatrixLogoutRequest,
        MatrixOidcAuthFinishRequest, MatrixOidcAuthRequest, MatrixRefreshSessionRequest,
        MatrixRefreshTokenRequest, MatrixSASConfirmRequest, MatrixSessionVerificationRequest,
        MatrixSyncBackgroundRequest, MatrixSyncCompleted, MatrixSyncOnceRequest,
        init_client_error::InitClientError,
    },
};

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

        let mut sdk_client = SdkClient::builder()
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

        let session_path = self.session_path();

        match tokio::fs::read_to_string(&session_path)
            .await
            .map(|file| serde_json::from_str::<Session>(&file))
        {
            Ok(Ok(session)) => {
                debug_print!("[init] session found: {:?}", session);
                sdk_client
                    .restore_session(AuthSession::from(&session))
                    .await
                    .expect("[init] failed to restore session");
            }
            Ok(Err(err)) => {
                debug_print!("[init] failed to parse file: {err:?}");
            }
            Err(err) => {
                debug_print!("[init] failed to read session file: {err:?}");
            }
        };

        debug_print!("[init] client was successfully restored");

        sdk_client
            .set_session_callbacks(
                {
                    let session_path = self.session_path();
                    let address = self.get_address();

                    Box::new(move |_client| {
                        debug_print!("SESSION CALLBACK RELOAD");
                        let session =
                            Session::load_from_disk(session_path.clone()).map_err(|err| {
                                Box::new(err) as Box<dyn std::error::Error + Send + Sync + 'static>
                            })?;

                        address.clone().emit(MatrixRefreshSessionRequest);

                        Ok(session.user_session.tokens)
                    })
                },
                {
                    let session_path = self.session_path();
                    let address = self.get_address();

                    Box::new(move |client| {
                        debug_print!("SESSION CALLBACK SAVE");

                        let oauth_session = client
                            .oauth()
                            .full_session()
                            .expect("after login, should have session");

                        let session = Session::from_oauth(oauth_session, session_path.clone());
                        session.save_to_disk().map_err(|err| {
                            Box::new(err) as Box<dyn std::error::Error + Send + Sync + 'static>
                        })?;

                        address.clone().emit(MatrixRefreshSessionRequest);

                        Ok(())
                    })
                },
            )
            .expect("[init_client] failed to set session callbacks");

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

            let _ = tokio::fs::remove_dir_all(&path).await;
            let _ = tokio::fs::remove_file(&path).await;
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
