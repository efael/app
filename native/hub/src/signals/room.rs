use std::sync::Arc;
use matrix_sdk::{
    Room as MatrixRoom,
    deserialized_responses::AnySyncOrStrippedState,
    ruma::events::{AnySyncStateEvent, StateEventType},
};
use rinf::{SignalPiece, debug_print};
use serde::Serialize;

#[derive(Serialize, SignalPiece, Debug)]
pub struct Room {
    pub id: String,
    pub name: Option<String>,
}

impl Room {
    pub async fn from_matrix(value: Arc<matrix_sdk_rinf::room::Room>) -> Self {
        // let name = value
        //     .get_state_events(StateEventType::RoomName)
        //     .await
        //     .map(|names| match names.last() {
        //         Some(AnySyncOrStrippedState::Sync(Box<AnySyncStateEvent::RoomName(name)>)) => Some(name),
        //         _ => None,
        //     });

        let name = value.display_name().unwrap();

        Self {
            id: value.id(),
            name: Some(name),
        }
    }
}
