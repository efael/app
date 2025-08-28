use matrix_sdk::authentication::matrix::MatrixSession;
use serde::{Deserialize, Serialize};

/// The full session to persist.
#[derive(Debug, Serialize, Deserialize)]
pub struct FullSession {
    /// The Matrix user session.
    pub user_session: MatrixSession,

    /// The latest sync token.
    ///
    /// It is only needed to persist it when using `Client::sync_once()` and we
    /// want to make our syncs faster by not receiving all the initial sync
    /// again.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub sync_token: Option<String>,
}
