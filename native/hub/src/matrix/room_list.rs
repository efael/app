use futures::{StreamExt, pin_mut};
use matrix_sdk::RoomState as SdkRoomState;
use matrix_sdk::locks::Mutex;
use matrix_sdk_ui::room_list_service::RoomList as SdkRoomList;
use matrix_sdk_ui::timeline::RoomExt;
use rinf::{RustSignal, debug_print};
use ruma::OwnedRoomId;
use std::collections::BTreeMap;
use std::str::FromStr;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tokio::task::{AbortHandle, JoinSet};

use crate::extensions::iter_await::IterAwait;
use crate::matrix::room::Room;
use crate::matrix::room_details::RoomDetails;
use crate::matrix::vector_diff_room::VectorDiffRoom;
use crate::signals::dart::MatrixRoomDiffResponse;

#[derive(Debug)]
pub struct RoomList {
    rooms: Arc<Mutex<BTreeMap<OwnedRoomId, RoomDetails>>>,
    last_updated: Arc<Mutex<u128>>,
    listener: Option<AbortHandle>,
}

impl Default for RoomList {
    fn default() -> Self {
        Self {
            rooms: Default::default(),
            last_updated: Arc::new(Mutex::new(0)),
            listener: None,
        }
    }
}

impl RoomList {
    #[tracing::instrument(skip(self))]
    pub fn listen_to_updates(&mut self, room_list: SdkRoomList, owned_tasks: &mut JoinSet<()>) {
        debug_print!("started listening to updates");
        let rooms = self.rooms.clone();
        let last_updated = self.last_updated.clone();

        let listener = owned_tasks.spawn(async move {
            let (stream, controller) = room_list.entries_with_dynamic_adapters(50);

            // don't really know what this is doing, copied from robrix
            controller.set_filter(Box::new(|_room| true));

            // this is required to call when initializing (e.g. hard reset in flutter or other cases)
            // controller.reset_to_one_page();

            pin_mut!(stream);
            while let Some(all_diffs) = stream.next().await {
                let diffs = IterAwait::new(all_diffs.into_iter().map(VectorDiffRoom::from_sdk))
                    .join_all_sorted()
                    .await;

                tokio::spawn(Self::handle_diffs(rooms.clone(), diffs.clone()));

                tracing::trace!("sending diff to dart");
                MatrixRoomDiffResponse(diffs).send_signal_to_dart();

                *last_updated.lock() = SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .expect("failed to fetch system-time")
                    .as_millis();

                tracing::trace!("room list last updated at - {:?}", last_updated.lock());
            }
        });

        self.listener = Some(listener);
    }

    pub async fn handle_diffs(
        rooms: Arc<Mutex<BTreeMap<OwnedRoomId, RoomDetails>>>,
        diffs: Vec<VectorDiffRoom>,
    ) {
        for diff in diffs {
            match diff {
                VectorDiffRoom::Append { values } => {
                    IterAwait::new(
                        values
                            .into_iter()
                            .map(|room| Self::handle_new_room(rooms.clone(), room)),
                    )
                    .join_set()
                    .join_all()
                    .await;
                }
                VectorDiffRoom::Clear => {
                    rooms.clone().lock().clear();
                }
                VectorDiffRoom::PushFront { value } => {
                    Self::handle_new_room(rooms.clone(), value).await;
                }
                VectorDiffRoom::PushBack { value } => {
                    Self::handle_new_room(rooms.clone(), value).await;
                }
                VectorDiffRoom::PopFront => {}
                VectorDiffRoom::PopBack => {}
                VectorDiffRoom::Insert {
                    index: _index,
                    value,
                } => {
                    Self::handle_new_room(rooms.clone(), value).await;
                }
                VectorDiffRoom::Set {
                    index: _indx,
                    value,
                } => {
                    Self::handle_new_room(rooms.clone(), value).await;
                }
                VectorDiffRoom::Remove { index: _index } => {}
                VectorDiffRoom::Truncate { length: _length } => {}
                VectorDiffRoom::Reset { values } => {
                    rooms.clone().lock().clear();
                    IterAwait::new(
                        values
                            .into_iter()
                            .map(|room| Self::handle_new_room(rooms.clone(), room)),
                    )
                    .join_set()
                    .join_all()
                    .await;
                }
            };
        }
    }

    pub async fn handle_new_room(
        rooms: Arc<Mutex<BTreeMap<OwnedRoomId, RoomDetails>>>,
        room: Room,
    ) {
        let room_id = OwnedRoomId::from_str(room.room_id()).expect("should parse room id");
        let room_name = &room.name;

        match room.inner.state() {
            SdkRoomState::Knocked => {
                tracing::trace!("Knocked room {room_id} {room_name}");
                return;
            }
            SdkRoomState::Left => {
                tracing::trace!("Left room {room_id} {room_name}");
                return;
            }
            SdkRoomState::Banned => {
                tracing::trace!("Banned room {room_id} {room_name}");
                return;
            }
            SdkRoomState::Invited => {
                tracing::trace!("Invited room {room_id} {room_name}");
                return;
            }
            SdkRoomState::Joined => {}
        };
        let timeline = room
            .inner
            .timeline_builder()
            .track_read_marker_and_receipts()
            .build()
            .await;

        let timeline = match timeline {
            Ok(timeline) => Arc::new(timeline),
            Err(err) => {
                tracing::error!(error = %err, "Failed to build timeline for {room_id} {room_name}");
                return;
            }
        };

        tracing::trace!("subscribing for {room_id} {room_name}");

        let s_timeline = timeline.clone();
        let subscription = tokio::spawn(async move {
            let (mut items, mut subscriber) = s_timeline.subscribe().await;
            tracing::trace!("items {items:?}");
            while let Some(s) = subscriber.next().await {
                tracing::trace!("something {s:?}");
            }
        });

        rooms.lock().insert(
            room_id,
            RoomDetails {
                room,
                timeline,
                subscription: Some(subscription),
            },
        );
    }
}
