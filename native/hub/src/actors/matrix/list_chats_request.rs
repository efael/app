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
    timeline::EventTimelineItem,
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

        // let sync_service = match self.sync_service.as_ref() {
        //     Some(sync_service) => sync_service.clone(),
        //     None => {
        //         debug_print!("[room] MatrixOidcAuthFinishRequest: sync service is not initialized");
        //         MatrixListChatsResponse::Err {
        //             message: "sync service is not initialized".to_string(),
        //         }
        //         .send_signal_to_dart();
        //         return;
        //     }
        // };

        // let room_service = match self.room_service.as_ref() {
        //     None => {
        //         let service = sync_service.room_list_service();

        //         self.room_service = Some(service.clone());
        //         service
        //     }
        //     Some(service) => service.clone(),
        // };

        // debug_print!("[room] subscribing to upcoming changes");
        // let res = room_service
        //     .clone()
        //     .all_rooms()
        //     .await
        //     .unwrap()
        //     .clone()
        //     .entries_with_dynamic_adapters(50, Box::new(RoomListNotifier));

        // res
        //     .controller()
        //     .set_filter(RoomListEntriesDynamicFilterKind::All {
        //         filters: vec![RoomListEntriesDynamicFilterKind::NonLeft],
        //     });

        // // don't know why, but without this, whole app crashes (UB)
        // // tokio::spawn(async move {
        // //     res.entries_stream().is_finished();
        // // });

        // // Static room list
        // debug_print!("[room] cache count = {}", client.rooms().len());
        // let mut set = JoinSet::new();

        // client.rooms().into_iter().for_each(|r| {
        //     set.spawn(async move {
        //         let info = r.room_info().await;
        //         let latest_event = r.latest_event_from_timeline().await;
        //         info.map(|info| (info, latest_event))
        //     });
        // });

        // let rooms = set
        //     .join_all()
        //     .await
        //     .into_iter()
        //     .filter_map(|r| r.ok())
        //     .collect();

        let rooms = Vec::new();
        MatrixListChatsResponse::Ok { rooms }.send_signal_to_dart();
    }
}

#[derive(Debug)]
struct RoomListNotifier;

impl RoomListEntriesListener for RoomListNotifier {
    fn on_update(&self, updates: Vec<RoomListEntriesUpdate>) {
        for update in updates {
            match update {
                RoomListEntriesUpdate::Reset { values }
                | RoomListEntriesUpdate::Append { values } => {
                    debug_print!("[update] got reset, rooms: {}", values.len());

                    tokio::spawn(async move {
                        let mut set = JoinSet::new();

                        values.into_iter().for_each(|r| {
                            set.spawn(async move {
                                debug_print!(
                                    "[update] room: {}",
                                    r.display_name().expect("does have a name")
                                );
                                debug_print!("- encryption_state: {:?}", r.encryption_state());
                                debug_print!(
                                    "- latest_encryption_state: {:?}",
                                    r.latest_encryption_state().await
                                );
                                debug_print!("----------------------------");

                                let info = r.room_info().await;
                                let latest_event = r.latest_event_from_timeline().await;
                                // debug_print!("- info: {:?}", info);
                                // debug_print!("- event: {:?}", latest_event);

                                info.map(|info| (info, latest_event))
                            });
                        });

                        let mut rooms: Vec<(RoomInfo, Option<EventTimelineItem>)> = set
                            .join_all()
                            .await
                            .into_iter()
                            .filter_map(|r| r.ok())
                            .collect();

                        rooms.sort_by(|a, b| match (&a.1, &b.1) {
                            (Some(a), Some(b)) => b.timestamp.0.cmp(&a.timestamp.0),
                            (Some(_), None) => std::cmp::Ordering::Less,
                            (None, Some(_)) => std::cmp::Ordering::Greater,
                            (None, None) => a.0.display_name.cmp(&b.0.display_name),
                        });

                        MatrixRoomListUpdate::List { rooms }.send_signal_to_dart();
                    });
                }
                RoomListEntriesUpdate::Remove { index } => {
                    debug_print!("[update] got remove, index: {index}");
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
