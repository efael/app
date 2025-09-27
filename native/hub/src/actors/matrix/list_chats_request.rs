use crate::{
    actors::matrix::Matrix,
    signals::{MatrixListChatsRequest, MatrixListChatsResponse, MatrixRoomListUpdate},
};
use async_trait::async_trait;
use matrix_sdk_rinf::{
    room::room_info::RoomInfo,
    room_list::{
        RoomListEntriesDynamicFilterKind, RoomListEntriesListener, RoomListEntriesUpdate,
        RoomListServiceStateListener,
    },
};
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};
use tokio::task::JoinSet;

#[async_trait]
impl Notifiable<MatrixListChatsRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixListChatsRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("[room] MatrixOidcAuthFinishRequest: client is not initialized");
                MatrixListChatsResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        let sync_service = match self.sync_service.as_ref() {
            Some(sync_service) => sync_service.clone(),
            None => {
                debug_print!("[room] MatrixOidcAuthFinishRequest: sync service is not initialized");
                MatrixListChatsResponse::Err {
                    message: "sync service is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        debug_print!("[room] started sync service inside list-chat");
        sync_service.start().await;

        let room_service = match self.room_service.as_ref() {
            None => {
                let service = sync_service.room_list_service();

                self.room_service = Some(service.clone());
                service
            }
            Some(service) => service.clone(),
        };

        // debug_print!("[room] subscribing to state changes");
        // room_service
        //     .state(Box::new(RoomStateListener));

        debug_print!("[room] subscribing to upcoming changes");
        let res = room_service
            .all_rooms()
            .await
            .unwrap()
            .clone()
            .entries_with_dynamic_adapters(50, Box::new(RoomListNotifier));

        let set_filter = res
            .controller()
            .set_filter(RoomListEntriesDynamicFilterKind::All {
                filters: vec![RoomListEntriesDynamicFilterKind::NonLeft],
            });
        debug_print!("[room] does filter set: {set_filter}");

        // self.rinf_taks.push(res.entries_stream());
        // tokio::thread::sleep(Duration::from_secs(5));

        // Static room list
        debug_print!("[room] room count = {}", client.rooms().len());

        let mut set = JoinSet::new();

        client.rooms().into_iter().for_each(|r| {
            set.spawn(async move {
                let info = r.room_info().await;
                let latest_event = r.latest_event().await;
                info.map(|info| (info, latest_event))
            });
        });

        let rooms = set
            .join_all()
            .await
            .into_iter()
            .filter_map(|r| r.ok())
            .collect();

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
                    tokio::spawn(async move {
                        let mut set = JoinSet::new();

                        values.into_iter().for_each(|r| {
                            set.spawn(async move {
                                let info = r.room_info().await;
                                let latest_event = r.latest_event().await;
                                info.map(|info| (info, latest_event))
                            });
                        });

                        let rooms = set
                            .join_all()
                            .await
                            .into_iter()
                            .filter_map(|r| r.ok())
                            .collect();

                        MatrixRoomListUpdate::List { rooms }.send_signal_to_dart();
                    });
                }
                RoomListEntriesUpdate::Remove { index } => {
                    MatrixRoomListUpdate::Remove {
                        indices: vec![index],
                    }
                    .send_signal_to_dart();
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
