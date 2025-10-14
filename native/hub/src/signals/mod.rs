pub mod init_client_error;
pub mod save_session_error;

use matrix_sdk::{config::SyncSettings, ruma::api::client::sync::sync_events, Client};
use matrix_sdk_rinf::{
    room::room_info::RoomInfo, timeline::EventTimelineItem
};
use rinf::{DartSignal, RustSignal};
use serde::{Deserialize, Serialize};

use crate::matrix::{oidc::OidcConfiguration, room::Room, sas_verification::Emoji};


#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixInitRequest {
    pub application_support_directory: String,
    pub homeserver_url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixInitResponse {
    Ok {
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

#[derive(Serialize, RustSignal)]
pub enum MatrixListChatsResponse {
    Ok {
        rooms: Vec<(RoomInfo, Option<EventTimelineItem>)>,
    },
    Err {
        message: String,
    },
}

#[derive(Serialize, RustSignal)]
pub enum MatrixRoomListUpdate {
    List {
        rooms: Vec<(RoomInfo, Option<EventTimelineItem>)>,
    },
    Remove {
        indices: Vec<u32>,
    },
}

#[derive(Deserialize, Serialize, DartSignal, Debug)]
pub struct MatrixSyncOnceRequest {
    pub sync_token: Option<String>
}

#[derive(Deserialize, Serialize, DartSignal, Debug)]
pub enum MatrixSyncBackgroundRequest {
    Start
}

#[derive(Deserialize, Serialize, DartSignal, Debug)]
pub struct MatrixSyncCompleted {
    pub next_batch: String
}


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