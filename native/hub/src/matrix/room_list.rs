use futures::{StreamExt, pin_mut};
use matrix_sdk::locks::Mutex;
use matrix_sdk::room::Room as SdkRoom;
use matrix_sdk::{Client, RoomState as SdkRoomState};
use matrix_sdk_ui::eyeball_im::VectorDiff;
use matrix_sdk_ui::room_list_service::RoomList as SdkRoomList;
use rinf::{RustSignal, debug_print};
use ruma::events::AnyTimelineEvent;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tokio::task::JoinSet;

use crate::extensions::iter_await::IterAwait;
use crate::matrix::room::Room;
use crate::matrix::vector_diff::VectorDiffRoom;
use crate::signals::MatrixRoomDiffResponse;

#[derive(Debug)]
pub struct RoomList {
    rooms: Arc<Mutex<Vec<Room>>>,
    last_updated: Arc<Mutex<u128>>,
}

impl Default for RoomList {
    fn default() -> Self {
        RoomList {
            rooms: Arc::new(Mutex::new(vec![])),
            last_updated: Arc::new(Mutex::new(0)),
        }
    }
}

impl RoomList {
    #[tracing::instrument(skip(self))]
    pub fn listen_to_updates(&self, room_list: SdkRoomList, owned_tasks: &mut JoinSet<()>) {
        debug_print!("started listening to updates");
        let cached_rooms = self.rooms.clone();
        let last_updated = self.last_updated.clone();

        owned_tasks.spawn(async move {
            let (stream, controller) = room_list.entries_with_dynamic_adapters(50);

            // don't really know what this is doing, copied from robrix
            controller.set_filter(Box::new(|_room| true));

            // this is required to call when initializing (e.g. hard reset in flutter or other cases)
            // controller.reset_to_one_page();

            pin_mut!(stream);
            while let Some(all_diffs) = stream.next().await {
                // RoomList::handle_diff(all_diffs.clone(), cached_rooms.clone()).await;
                let diffs = IterAwait::new(all_diffs.into_iter().map(VectorDiffRoom::from_sdk))
                    .join_all_sorted()
                    .await;

                tracing::trace!("sending diff to dart");
                MatrixRoomDiffResponse::Ok { diffs }.send_signal_to_dart();

                *last_updated.lock() = SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .expect("failed to fetch system-time")
                    .as_millis();

                for r in cached_rooms.lock().iter() {
                    debug_print!("* room - {:?}", r.name);
                    debug_print!("{:?}", r);
                    debug_print!("");
                }

                debug_print!("* room list last updated at - {:?}", last_updated.lock());
            }
        });
    }

    async fn handle_diff(all_diffs: Vec<VectorDiff<SdkRoom>>, cached_rooms: Arc<Mutex<Vec<Room>>>) {
        for diff in all_diffs {
            match diff {
                VectorDiff::Append { values: new_rooms } => {
                    debug_print!("[diff] got APPEND");
                }
                VectorDiff::Clear => {
                    debug_print!("[diff] got CLEAR");
                }
                VectorDiff::PushFront { value: new_room } => {
                    debug_print!("[diff] got CLEAR");
                }
                VectorDiff::Insert {
                    index,
                    value: new_room,
                } => {
                    debug_print!("[diff] got INSERT");
                }

                VectorDiff::PopFront => {
                    debug_print!("[diff] got PopFront");
                }

                VectorDiff::PopBack => {
                    debug_print!("[diff] got PopBack");
                }

                VectorDiff::PushBack { value } => {
                    debug_print!("[diff] got PushBack");
                }

                VectorDiff::Set { index, value } => {
                    debug_print!("[diff] got Set");
                }

                VectorDiff::Remove { index } => {
                    debug_print!("[diff] got Remove");
                }

                VectorDiff::Truncate { length } => {
                    debug_print!("[diff] got Truncate");
                }

                VectorDiff::Reset { values: new_rooms } => {
                    debug_print!("[diff] got RESET");

                    cached_rooms.lock().clear();
                    let new_rooms = new_rooms
                        .into_iter()
                        .map(|sdk_room| async move { Room::from_sdk_room(sdk_room).await });

                    let new_rooms = futures::future::join_all(new_rooms).await;
                    *cached_rooms.lock() = new_rooms;
                }
            }
        }
    }

    pub async fn populate(&self, client: &Client) {
        // debug_print!("[room-list] populating room cache");

        // let rooms = client
        //     .joined_rooms()
        //     .into_iter()
        //     .map(|sdk_room| async move { Room::from_sdk_room(sdk_room.clone()).await });

        // let rooms = futures::future::join_all(rooms).await;
        // *self.rooms.lock() = rooms;

        // debug_print!("[room-list] room cache populated successfully");
    }

    pub fn get_rooms(&self) -> Vec<Room> {
        self.rooms.lock().clone()
    }

    pub fn wrap(&self, other_room: &Room) -> Option<Room> {
        let rooms = self.rooms.lock();

        for room in rooms.iter() {
            if room.room_id() == other_room.room_id() {
                return Some(room.clone());
            }
        }

        None
    }

    pub fn room_visit_event(&self, other_room: Room) {
        let mut rooms = self.rooms.lock();

        for room in rooms.iter_mut() {
            if room.room_id() == other_room.room_id() {
                room.is_visited = true;
                return;
            }
        }
    }

    pub async fn timeline_event(&self, client: Client, event: &AnyTimelineEvent) {
        let sdk_room = match client.get_room(event.room_id()) {
            Some(room) => room,
            None => return,
        };

        if sdk_room.state() != SdkRoomState::Joined {
            return;
        }

        let created_room = Room::from_sdk_room(sdk_room).await;
        let mut rooms = self.rooms.lock();
        for room in rooms.iter_mut() {
            if room.room_id() == event.room_id() {
                *room = created_room;
                return;
            }
        }

        debug_print!("[room-list] A room has appeared! {}", created_room.name);
        rooms.insert(0, created_room);
    }
}
