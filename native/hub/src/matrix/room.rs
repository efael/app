use matrix_sdk::room::{MessagesOptions, Room as SdkRoom};
use matrix_sdk::{Error, RoomDisplayName};
use rinf::{debug_print, SignalPiece};
use ruma::api::Direction;
use ruma::events::room::message::MessageType;
use ruma::{MilliSecondsSinceUnixEpoch, RoomId};
use serde::{Deserialize, Serialize};

use crate::matrix::events;

#[derive(Debug, Clone)]
pub struct Room {
    pub inner: SdkRoom,
    pub name: RoomDisplayName,
    pub visited: bool,
    pub last_message: Option<String>,
    pub last_sender: Option<String>,
    pub last_ts: Option<MilliSecondsSinceUnixEpoch>,
}

impl Room {
    pub fn room_id(&self) -> &RoomId {
        self.inner.room_id()
    }

    pub fn inner(&self) -> SdkRoom {
        self.inner.clone()
    }

    pub fn unread_count(&self) -> u64 {
        if self.visited {
            return 0;
        }

        self.inner.unread_notification_counts().notification_count
    }

    pub fn highlight_count(&self) -> u64 {
        if self.visited {
            return 0;
        }

        self.inner.unread_notification_counts().highlight_count
    }

    pub async fn from_room(room: SdkRoom) -> Room {
        let name = room
            .cached_display_name()
            .unwrap_or(RoomDisplayName::Named("Unknown".to_string()));

        async fn inner(room: SdkRoom, name: RoomDisplayName) -> Result<Room, Error> {
            let timeline_messages = match room
                .messages(MessagesOptions::new(Direction::Backward))
                .await
            {
                Ok(messages) => messages.chunk,
                Err(err) => {
                    debug_print!("[room] failed to fetch messages: {err:?}");
                    Vec::new()
                }
            };

            let mut latest_ts: Option<MilliSecondsSinceUnixEpoch> = None;

            for timeline_event in &timeline_messages {
                if latest_ts.is_none() {
                    if let Ok(event) =
                        events::deserialize_event(timeline_event, room.room_id().to_owned())
                    {
                        latest_ts = Some(event.origin_server_ts());
                    }
                }

                let event = match events::get_room_message_event(&room, timeline_event) {
                    Some(event) => event,
                    None => {
                        continue;
                    }
                };

                let (body, original_event) = match event.as_original() {
                    None => {
                        continue;
                    }
                    Some(original_event) => {
                        if let MessageType::Text(content) = &original_event.content.msgtype {
                            (content.body.clone(), original_event)
                        } else {
                            ("".to_string(), original_event)
                        }
                    }
                };

                let member = room
                    .get_member(&original_event.sender)
                    .await
                    .map_err(Error::from)?
                    .unwrap();

                return Ok(Room {
                    inner: room,
                    name,
                    visited: false,
                    last_message: Some(body),
                    last_sender: Some(member.name().to_string()),
                    last_ts: latest_ts,
                });
            }

            Ok(Room {
                inner: room,
                name,
                visited: false,
                last_message: None,
                last_sender: None,
                last_ts: latest_ts,
            })
        }

        match inner(room.clone(), name.clone()).await {
            Ok(r) => r,
            Err(e) => {
                debug_print!("could not fetch room details: {:?}", e);
                Room {
                    inner: room,
                    name,
                    visited: false,
                    last_message: None,
                    last_sender: None,
                    last_ts: None,
                }
            }
        }
    }
}
