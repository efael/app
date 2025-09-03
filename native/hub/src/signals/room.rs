use matrix_sdk::{
    Room as MatrixRoom,
    deserialized_responses::AnySyncOrStrippedState,
    ruma::events::{AnySyncStateEvent, StateEventType},
};
use rinf::{SignalPiece, debug_print};
use serde::Serialize;

#[derive(Serialize, SignalPiece, Debug)]
pub struct Room {
    pub name: Option<String>,
}

impl Room {
    pub async fn from_matrix(value: MatrixRoom) -> Self {
        // let name = value
        //     .get_state_events(StateEventType::RoomName)
        //     .await
        //     .map(|names| match names.last() {
        //         // Some(AnySyncOrStrippedState::Sync(Box<AnySyncStateEvent::RoomName(name)>)) => Some(name),
        //         _ => None,
        //     });
        //
        // debug_print!("{name:?}");
        Self { name: None }
    }
}
