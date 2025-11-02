use std::sync::Arc;

use matrix_sdk_ui::{Timeline, eyeball_im::Vector};
use tokio::task::AbortHandle;

use crate::matrix::{room::Room, timeline::TimelineItem};

#[derive(Debug)]
pub struct RoomDetails {
    pub room: Room,
    pub initial_items: Vector<TimelineItem>,
    pub timeline: Arc<Timeline>,
    pub subscription: Option<AbortHandle>,
}
