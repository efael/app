use rinf::DartSignal;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, DartSignal, Debug)]
pub enum InternalSyncBackgroundRequest {
    Start,
}

// ---

#[derive(Deserialize, Serialize, DartSignal, Debug)]
pub struct InternalRefreshSessionRequest;
