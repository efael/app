use crate::matrix::room::Room;
use matrix_sdk::locks::Mutex;
use matrix_sdk::room::{Room as SdkRoom};
use matrix_sdk::{Client, RoomState as SdkRoomState};
use rinf::debug_print;
use ruma::events::AnyTimelineEvent;

pub struct RoomList {
    rooms: Mutex<Vec<Room>>,
}

impl Default for RoomList {
    fn default() -> Self {
        RoomList {
            rooms: Mutex::new(vec![]),
        }
    }
}

impl RoomList {
    pub async fn populate(&self, client: &Client) {
        debug_print!("[room-list] populating room cache");

        let rooms = client
            .joined_rooms()
            .into_iter()
            .map(|sdk_room| async move { Room::from_sdk_room(sdk_room.clone()).await });

        let rooms = futures::future::join_all(rooms).await;
        *self.rooms.lock() = rooms;

        debug_print!("[room-list] room cache populated successfully");
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
