pub mod full_session;
pub mod homeserver_login_details;
pub mod init_client_error;
pub mod logout_error;
pub mod oidc_configuration;
pub mod oidc_error;
pub mod oidc_prompt;
pub mod save_session_error;
pub mod sliding_sync_version;

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
