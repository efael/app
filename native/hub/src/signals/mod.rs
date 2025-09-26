pub mod init_client_error;
pub mod save_session_error;

use matrix_sdk::{Client, config::SyncSettings, ruma::api::client::sync::sync_events};
use matrix_sdk_rinf::{
    authentication::{HomeserverLoginDetails, OidcConfiguration},
    room::room_info::RoomInfo,
};
use rinf::{DartSignal, RustSignal};
use serde::{Deserialize, Serialize};

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
    OK,
}

#[derive(Deserialize, DartSignal, Debug)]
pub enum MatrixProcessSyncResponseRequest {
    #[serde(skip)]
    Response(sync_events::v3::Response),
    OK,
}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixLogoutRequest {}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixRefreshTokenRequest {
    pub sync_token: Option<String>,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixLogoutResponse {
    Ok,
    Err { message: String },
}

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixListChatsRequest {
    pub url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixListChatsResponse {
    Ok { rooms: Vec<RoomInfo> },
    Err { message: String },
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixRoomListUpdate {
    List { rooms: Vec<RoomInfo> },
    Remove { indices: Vec<u32> },
}

#[derive(Deserialize, Serialize, DartSignal, Debug)]
pub enum MatrixSyncServiceRequest {
    Loop,
    Stop,
}
