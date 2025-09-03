pub mod full_session;
pub mod homeserver_login_details;
pub mod init_client_error;
pub mod logout_error;
pub mod oidc_configuration;
pub mod oidc_error;
pub mod oidc_prompt;
pub mod room;
pub mod save_session_error;
pub mod sliding_sync_version;

use matrix_sdk::{
    Client, authentication::matrix::MatrixSession, config::SyncSettings,
    ruma::api::client::sync::sync_events, sync::SyncResponse,
};
use rinf::{DartSignal, RustSignal};
use serde::{Deserialize, Serialize};

use crate::signals::{
    homeserver_login_details::HomeserverLoginDetails, oidc_configuration::OidcConfiguration,
};

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixInitRequest {
    pub application_support_directory: String,
    pub homeserver_url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixInitResponse {
    Ok {
        homeserver_login_details: HomeserverLoginDetails,
        is_active: bool,
        is_logged_in: bool,
    },
    Err {
        message: String,
    },
}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixOidcAuthRequest {
    pub oidc_configuration: OidcConfiguration,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixOidcAuthResponse {
    Ok { url: String },
    Err { message: String },
}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixOidcAuthFinishRequest {
    pub url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixOidcAuthFinishResponse {
    Ok,
    Err { message: String },
}

#[derive(Deserialize, DartSignal, Debug)]
pub enum MatrixSyncRequest {
    #[serde(skip)]
    Init {
        client: Client,
        sync_token: Option<String>,
    },
    #[serde(skip)]
    Continue {
        sync_settings: SyncSettings,
        sync_token: Option<String>,
    },
}

#[derive(Deserialize, DartSignal, Debug)]
pub enum MatrixProcessSyncResponseRequest {
    #[serde(skip)]
    Response(sync_events::v3::Response),
}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixLogoutRequest {}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixRefreshTokenRequest {
    pub sync_token: Option<String>,
}

#[derive(Serialize, RustSignal, Debug)]
pub struct MatrixLogoutResponse {}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixListChatsRequest {
    pub url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixListChatsResponse {
    Ok,
    Err { message: String },
}
