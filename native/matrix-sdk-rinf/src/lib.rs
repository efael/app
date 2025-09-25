#![allow(unused_qualifications, clippy::new_without_default)]
// Needed because uniffi macros contain empty lines after docs.
#![allow(clippy::empty_line_after_doc_comments)]

pub mod authentication;
pub mod chunk_iterator;
pub mod client;
pub mod client_builder;
pub mod encryption;
pub mod error;
pub mod event;
pub mod helpers;
pub mod identity_status_change;
pub mod live_location_share;
pub mod notification;
pub mod notification_settings;
pub mod platform;
pub mod qr_code;
pub mod room;
pub mod room_alias;
pub mod room_directory_search;
pub mod room_list;
pub mod room_member;
pub mod room_preview;
pub mod ruma;
pub mod runtime;
pub mod session_verification;
pub mod sync_service;
pub mod task_handle;
pub mod timeline;
pub mod tracing;
pub mod utd;
pub mod utils;
pub mod widget;

use self::{error::ClientError, task_handle::TaskHandle};

pub fn sdk_git_sha() -> String {
    // env!("VERGEN_GIT_SHA").to_owned()
    "".to_string()
}
