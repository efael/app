use futures::{StreamExt, pin_mut};
use matrix_sdk::RoomState as SdkRoomState;
use matrix_sdk_ui::eyeball_im::Vector;
use matrix_sdk_ui::room_list_service::RoomList as SdkRoomList;
use matrix_sdk_ui::timeline::RoomExt;
use rinf::{RustSignal, debug_print};
use ruma::OwnedRoomId;
use std::collections::BTreeMap;
use std::ops::DerefMut;
use std::str::FromStr;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tokio::sync::Mutex;
use tokio::task::AbortHandle;

use crate::extensions::iter_await::IterAwait;
use crate::matrix::room::Room;
use crate::matrix::room_details::RoomDetails;
use crate::matrix::timeline::TimelineItem;
use crate::matrix::vector_diff_room::VectorDiffRoom;
use crate::matrix::vector_diff_timeline_item::VectorDiffTimelineItem;
use crate::signals::dart::{MatrixRoomDiffResponse, MatrixTimelineItemDiffResponse};

#[derive(Debug)]
pub struct RoomList {
    pub rooms: Arc<Mutex<BTreeMap<OwnedRoomId, RoomDetails>>>,
    pub last_updated: Arc<Mutex<u128>>,
    pub listener: Option<AbortHandle>,
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
    pub fn listen_to_updates(&mut self, room_list: SdkRoomList) {
        debug_print!("started listening to updates");
        let rooms = self.rooms.clone();
        let last_updated = self.last_updated.clone();

        let listener = tokio::spawn(async move {
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

                let mut last_updated = last_updated.lock().await;
                let last_updated = last_updated.deref_mut();
                *last_updated = SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .expect("failed to fetch system-time")
                    .as_millis();

                tracing::trace!("room list last updated at - {:?}", last_updated);
            }
        });

        self.listener = Some(listener.abort_handle());
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
                    rooms.clone().lock().await.clear();
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
                    rooms.clone().lock().await.clear();
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

        let is_subsrcibed = {
            rooms
                .lock()
                .await
                .get(&room_id)
                .map_or_else(|| false, |d| d.subscription.is_some())
        };

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

        if is_subsrcibed {
            return;
        }

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

        let s_room_id = room_id.clone();
        let s_rooms = rooms.clone();
        let s_timeline = timeline.clone();
        let subscription = tokio::spawn(async move {
            let (items, mut subscriber) = s_timeline.subscribe().await;
            tracing::trace!("i am spawned {s_room_id}");
            {
                let items: Vector<TimelineItem> = items.into_iter().map(Into::into).collect();
                let mut rooms = s_rooms.lock().await;
                // FIXME: data race promise. needs to revisit in the future
                let room_details = rooms.get_mut(&s_room_id).expect("should exist already");
                if room_details.initial_items.is_empty() {
                    room_details.initial_items.append(items);
                }
            }
            while let Some(diffs) = subscriber.next().await {
                let diffs: Vec<VectorDiffTimelineItem> = diffs
                    .into_iter()
                    .map(VectorDiffTimelineItem::from_sdk)
                    .collect();
                tracing::trace!("timeline received new message {s_room_id}");
                tracing::trace!("timeline something {diffs:?}");
                
                let mut rooms = s_rooms.lock().await;
                let room_details = rooms.get_mut(&s_room_id).expect("should exist already");

                let diffs_for_send = diffs.clone();

                for diff in diffs {
                    diff.apply(&mut room_details.initial_items);
                }

                MatrixTimelineItemDiffResponse(s_room_id.to_string(), diffs_for_send)
                    .send_signal_to_dart();
            }
        });

        rooms.lock().await.insert(
            room_id,
            RoomDetails {
                room,
                initial_items: Vector::new(),
                timeline,
                subscription: Some(subscription.abort_handle()),
            },
        );
    }

    pub async fn cleanup(&mut self) {
        if let Some(listener) = self.listener.take() {
            listener.abort();
        }

        let mut rooms = self.rooms.lock().await;
        for (_, room) in rooms.iter_mut() {
            if let Some(subscription) = room.subscription.take() {
                subscription.abort();
            }
        }
    }
}
