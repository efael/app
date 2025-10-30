use rinf::{DartSignal, RustSignal};
use serde::{Deserialize, Serialize};

use crate::matrix::{
    oidc::OidcConfiguration, sas_verification::Emoji, vector_diff_room::VectorDiffRoom,
};

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixInitRequest {
    pub application_support_directory: String,
    pub homeserver_url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixInitResponse {
    Ok { is_active: bool, is_logged_in: bool },
    Err { message: String },
}

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixOidcAuthRequest {
    pub oidc_configuration: OidcConfiguration,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixOidcAuthResponse {
    Ok { url: String },
    Err { message: String },
}

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixOidcAuthFinishRequest {
    pub url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixOidcAuthFinishResponse {
    Ok,
    Err { message: String },
}

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixLogoutRequest {}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixLogoutResponse {
    Ok,
    Err { message: String },
}

// ---

#[derive(Serialize, RustSignal)]
pub struct MatrixRoomDiffResponse(pub Vec<VectorDiffRoom>);

// ---

#[derive(Deserialize, Serialize, DartSignal, Debug)]
pub enum MatrixSessionVerificationRequest {
    Start,
    Stop,
}

#[derive(Deserialize, Serialize, DartSignal, Debug)]
pub struct MatrixSASConfirmRequest {
    pub flow_id: String,
    pub emojis: Vec<Emoji>,
}
