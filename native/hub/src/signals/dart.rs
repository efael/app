#![allow(dead_code, clippy::large_enum_variant)]
use rinf::{DartSignal, RustSignal, SignalPiece};
use serde::{Deserialize, Serialize};

use crate::matrix::{
    oidc::OidcConfiguration, sas_verification::Emoji, timeline_pagination::TimelinePagination,
    vector_diff_room::VectorDiffRoom, vector_diff_timeline_item::VectorDiffTimelineItem
};

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixInitRequest {
    pub application_support_directory: String,
    pub homeserver_url: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixInitResponse {
    LoggedIn(String),
    NotLoggedIn,
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
    Ok { user_id: String },
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

#[derive(Serialize, RustSignal)]
pub struct MatrixTimelineItemDiffResponse(pub String, pub Vec<VectorDiffTimelineItem>);

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

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixFetchRoomRequest {
    pub room_id: String,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixFetchRoomResponse {
    Ok {
        room_id: String,
        diff: VectorDiffTimelineItem,
    },
    Err {
        message: String,
    },
}

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixTimelinePaginateRequest {
    pub room_id: String,
    pub pagination: TimelinePagination,
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixTimelinePaginateResponse {
    Ok {
        room_id: String,
        end_of_timeline: bool
    },
    Err {
        message: String,
    },
}

// ---

#[derive(Deserialize, DartSignal, Debug)]
pub struct MatrixSendMessageRequest {
    pub room_id: String,
    pub content: MatrixSendMessageContent,
}

#[derive(Deserialize, SignalPiece, Debug)]
pub enum MatrixSendMessageContent {
    Message { body: String },
}

#[derive(Serialize, RustSignal, Debug)]
pub enum MatrixSendMessageResponse {
    Ok {},
    Err { message: String },
}
