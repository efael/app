use std::{io::ErrorKind, path::PathBuf};

use async_trait::async_trait;
use matrix_sdk::{
    Client, authentication::oauth::OAuthAuthorizationData, reqwest::Url, ruma::exports::serde_json,
};
use messages::{
    actor::Actor,
    prelude::{Address, Context, Notifiable},
};
use rinf::{RustSignal, debug_print};
use tokio::task::JoinSet;

use crate::{
    extensions::easy_listener::EasyListener,
    signals::{
        MatrixInitRequest, MatrixInitResponse, MatrixOidcAuthFinishRequest,
        MatrixOidcAuthFinishResponse, MatrixOidcAuthRequest, MatrixOidcAuthResponse,
        full_session::FullSession, homeserver_login_details::HomeserverLoginDetails,
        init_client_error::InitClientError, logout_error::LogoutError,
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

#[async_trait]
impl Notifiable<MatrixInitRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixInitRequest, _: &Context<Self>) {
        if self.client.is_some() {
            debug_print!("MatrixInitRequest: client is already initialized");
            MatrixInitResponse::Err {
                message: "Client is already initialized".to_string(),
            }
            .send_signal_to_dart();
            return;
        }

        let application_support_directory = PathBuf::from(&msg.application_support_directory);

        self.application_support_directory = Some(application_support_directory);

        if let Err(err) = self.init_client(msg.homeserver_url).await {
            debug_print!("MatrixInitRequest: failed to initialize client: {err:?}");
            MatrixInitResponse::Err {
                message: err.to_string(),
            }
            .send_signal_to_dart();
            return;
        }

        let client = self
            .client
            .as_ref()
            .expect("MatrixInitClient: client should exist already");

        let homeserver_login_details = HomeserverLoginDetails::from_client(client).await;

        let response = MatrixInitResponse::Ok {
            homeserver_login_details,
            is_active: client.is_active(),
            is_logged_in: client.auth_api().is_some(),
        };

        debug_print!("MatrixInitRequest: client was successfully initialized: {response:?}");
        response.send_signal_to_dart();
    }
}

#[async_trait]
impl Notifiable<MatrixOidcAuthRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixOidcAuthRequest, _: &Context<Self>) {
        if let Err(err) = self.logout().await {
            debug_print!("MatrixOidcAuthRequest: failed to logout: {err:?}");
            MatrixOidcAuthResponse::Err {
                message: err.to_string(),
            }
            .send_signal_to_dart();
            return;
        }

        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixOidcAuthRequest: client is not initialized");
                MatrixOidcAuthResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        let registration_data = match msg.oidc_configuration.registration_data() {
            Ok(registration_data) => registration_data,
            Err(err) => {
                debug_print!("MatrixOidcAuthRequest: registration_data error: {err:?}");
                MatrixOidcAuthResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };
        let redirect_uri = match msg.oidc_configuration.redirect_uri() {
            Ok(redirect_uri) => redirect_uri,
            Err(err) => {
                debug_print!("MatrixOidcAuthRequest: redirect_uri error: {err:?}");
                MatrixOidcAuthResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        // let device_id = device_id.map(OwnedDeviceId::from);
        let device_id = None;

        let url_builder = client
            .oauth()
            .login(redirect_uri, device_id, Some(registration_data));

        // if let Some(prompt) = prompt {
        //     url_builder = url_builder.prompt(vec![prompt.into()]);
        // }
        // if let Some(login_hint) = login_hint {
        //     url_builder = url_builder.login_hint(login_hint);
        // }

        match url_builder.build().await {
            Ok(OAuthAuthorizationData { url, state: _ }) => {
                debug_print!("MatrixOidcAuthRequest: url built: {url:?}");
                MatrixOidcAuthResponse::Ok {
                    url: url.to_string(),
                }
                .send_signal_to_dart();
            }
            Err(err) => {
                debug_print!("MatrixOidcAuthRequest: url build error: {err:?}");
                MatrixOidcAuthResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
            }
        };
    }
}

#[async_trait]
impl Notifiable<MatrixOidcAuthFinishRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixOidcAuthFinishRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixOidcAuthFinishRequest: client is not initialized");
                MatrixOidcAuthFinishResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        let url = match Url::parse(msg.url.as_ref()) {
            Ok(url) => url,
            Err(err) => {
                debug_print!("MatrixOidcAuthFinishRequest: url parse error: {err:?}");
                MatrixOidcAuthFinishResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        match client.oauth().finish_login(url.into()).await {
            Ok(_) => {
                debug_print!("MatrixOidcAuthFinishRequest: logged in");

                if let Err(err) = self.save_session().await {
                    debug_print!("MatrixOidcAuthFinishRequest: failed to save session: {err:?}");
                }

                MatrixOidcAuthFinishResponse::Ok {}.send_signal_to_dart();
            }
            Err(err) => {
                debug_print!("MatrixOidcAuthFinishRequest: failed to finish login: {err:?}");
                MatrixOidcAuthFinishResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
            }
        };
    }
}
