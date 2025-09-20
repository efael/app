use std::time::Duration;
use async_trait::async_trait;
use matrix_sdk_rinf::room_list::{RoomListEntriesListener, RoomListEntriesUpdate, RoomListServiceStateListener};
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};
use crate::{
    actors::matrix::Matrix,
    signals::{room::Room, MatrixListChatsRequest, MatrixListChatsResponse, MatrixRoomListUpdate},
};

#[async_trait]
impl Notifiable<MatrixListChatsRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixListChatsRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("[room]atrixOidcAuthFinishRequest: client is not initialized");
                MatrixListChatsResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        // Subscribing to any updates on rooms
        let service = client
            .sync_service()
            .finish()
            .await
            .unwrap();

        debug_print!("[room] started sync service inside list-chat");
        service
            .start()
            .await;

        let room_list_service = service.room_list_service();
        debug_print!("[room] subscribing to state changes");
        room_list_service
            .state(Box::new(RoomStateListener));

        debug_print!("[room] subscribing to upcoming changes");
        room_list_service
            .clone()
            .all_rooms()
            .await
            .unwrap()
            .clone()
            .entries_with_dynamic_adapters(50, Box::new(RoomListNotifier));

        std::thread::sleep(Duration::from_secs(5));

        // Static room list
        debug_print!("[room] room count = {}", client.rooms().len());
        let mut rooms = vec![];

        for matrix_room in client.rooms() {
            let room = Room::from_matrix(matrix_room).await;
            rooms.push(room);
        }

        MatrixListChatsResponse::Ok { rooms }.send_signal_to_dart();
    }
}

#[derive(Debug)]
struct RoomListNotifier;

impl RoomListEntriesListener for RoomListNotifier {
    fn on_update(&self, updates: Vec<RoomListEntriesUpdate>) {
        debug_print!("[room] received an update - {}", updates.len());
        for update in updates {
            match update {
                RoomListEntriesUpdate::Reset { values } 
                | RoomListEntriesUpdate::Append { values } => {
                    let rooms: Vec<Room> = values
                        .into_iter()
                        .map(|r| Room {
                            id: r.id(),
                            name: r.display_name(),
                        })
                        .collect();

                    MatrixRoomListUpdate::List { rooms }.send_signal_to_dart();
                }
                RoomListEntriesUpdate::Remove { index } => {
                    MatrixRoomListUpdate::Remove { indices: vec![index] }.send_signal_to_dart();
                }
                unimplemented => {
                    debug_print!("[room] not implemented change!");
                }
            }
        }
    }
}

#[derive(Debug)]
struct RoomStateListener;

impl RoomListServiceStateListener for RoomStateListener {
    fn on_update(&self, state: matrix_sdk_rinf::room_list::RoomListServiceState) {
        debug_print!("[room] room list state = {state:?}");
    }
}