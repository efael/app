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
    pub async fn populate(&self, client: Client) {
        debug_print!("[room-list] populating room cache");

        let rooms = client
            .joined_rooms()
            .into_iter()
            .map(|r| async move { Room::from_room(r.clone()).await });

        let rooms = futures::future::join_all(rooms).await;

        let mut old_rooms = self.rooms.lock();

        *old_rooms = rooms;

        debug_print!("[room-list] room cache populated")
    }

    pub fn get_rooms(&self) -> Vec<Room> {
        self.rooms.lock().clone()
    }

    pub fn wrap(&self, room: &Room) -> Option<Room> {
        let rooms = self.rooms.lock();

        for r in rooms.iter() {
            if r.inner.room_id() == room.room_id() {
                return Some(r.clone());
            }
        }

        None
    }

    pub fn room_visit_event(&self, room: Room) {
        let mut rooms = self.rooms.lock();

        for dec in rooms.iter_mut() {
            if dec.inner.room_id() == room.room_id() {
                dec.visited = true;
                return;
            }
        }
    }

    pub async fn timeline_event(&self, client: Client, event: &AnyTimelineEvent) {
        let room = match client.get_room(event.room_id()) {
            Some(room) => room,
            None => return,
        };

        if room.state() != SdkRoomState::Joined {
            return;
        }

        let decorated = Room::from_room(room).await;

        let mut rooms = self.rooms.lock();

        for dec in rooms.iter_mut() {
            if dec.inner.room_id() == event.room_id() {
                *dec = decorated;
                return;
            }
        }

        debug_print!("[room-list] A wild room has appeared! {}", decorated.name);
        rooms.insert(0, decorated);
    }
}
