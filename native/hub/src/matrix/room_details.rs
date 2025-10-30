use std::sync::Arc;

use matrix_sdk_ui::Timeline;
use tokio::task::JoinHandle;

use crate::matrix::room::Room;

#[derive(Debug)]
pub struct RoomDetails {
    pub room: Room,
    pub timeline: Arc<Timeline>,
    pub subscription: Option<JoinHandle<()>>,
}
