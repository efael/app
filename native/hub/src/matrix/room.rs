use matrix_sdk::room::{MessagesOptions, Room as SdkRoom};
use matrix_sdk::sync::UnreadNotificationsCount as SdkUnreadNotificationsCount;
use matrix_sdk::{EncryptionState, Error, RoomDisplayName};
use rinf::{SignalPiece, debug_print};
use ruma::api::Direction;
use ruma::events::room::message::MessageType;
use serde::{Deserialize, Serialize};

use crate::matrix::events;
use crate::matrix::room_avatar::{RoomPreviewAvatar, AVATAR_THUMBNAIL_FORMAT};

#[derive(Debug, Clone, Serialize, Deserialize, SignalPiece)]
pub struct Room {
    // #[serde(skip)]
    // pub inner: SdkRoom,
    pub id: String,
    pub name: String,
    pub avatar: RoomPreviewAvatar,

    pub is_visited: bool,
    pub is_favourite: bool,
    pub is_encrypted: bool,

    pub unread_notification_counts: UnreadNotificationsCount,

    pub last_message: Option<String>,
    pub last_sender: Option<String>,
    pub last_ts: Option<u128>,
}

impl Room {
    pub fn room_id(&self) -> &String {
        &self.id
    }

    pub fn unread_count(&self) -> u64 {
        if self.is_visited {
            return 0;
        }

        self.unread_notification_counts.notification_count
    }

    pub fn highlight_count(&self) -> u64 {
        if self.is_visited {
            return 0;
        }

        self.unread_notification_counts.highlight_count
    }

    pub async fn from_sdk_room(sdk_room: SdkRoom) -> Self {
        let name = sdk_room
            .cached_display_name()
            .unwrap_or(RoomDisplayName::Named("Unknown".to_string()));

        let is_encrypted = !matches!(sdk_room.encryption_state(), EncryptionState::NotEncrypted);

        let avatar = match sdk_room.avatar(AVATAR_THUMBNAIL_FORMAT.into()).await {
            Ok(Some(avatar)) => RoomPreviewAvatar::Image(avatar),
            _ => {
                RoomPreviewAvatar::Text("A".to_string())
            }
        };

        let mut room = Room {
            id: sdk_room.room_id().to_string(),
            name: name.to_room_alias_name(),
            avatar,
            is_visited: false,
            is_encrypted,
            is_favourite: sdk_room.is_favourite(),
            unread_notification_counts: UnreadNotificationsCount::from(
                sdk_room.unread_notification_counts(),
            ),
            last_message: None,
            last_sender: None,
            last_ts: None,
        };

        async fn construct_latest(room: &mut Room, sdk_room: SdkRoom) -> Result<(), Error> {
            let timeline_messages = match sdk_room
                .messages(MessagesOptions::new(Direction::Backward))
                .await
            {
                Ok(messages) => messages.chunk,
                Err(err) => {
                    debug_print!("[room] failed to fetch messages: {err:?}");
                    Vec::new()
                }
            };

            let mut latest_ts: Option<u128> = None;
            for timeline_event in &timeline_messages {
                if latest_ts.is_none()
                    && let Ok(event) =
                        events::deserialize_event(timeline_event, room.room_id().clone())
                {
                    latest_ts = Some(event.origin_server_ts().0.into());
                }

                let event = match events::get_room_message_event(&sdk_room, timeline_event) {
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

                let member = sdk_room.get_member(&original_event.sender).await?.unwrap();

                room.last_message = Some(body);
                room.last_sender = Some(member.name().to_string());
                room.last_ts = latest_ts;

                return Ok(());
            }

            room.last_ts = latest_ts;
            Ok(())
        }

        if let Err(err) = construct_latest(&mut room, sdk_room).await {
            debug_print!("[room] failed to construct latest events {err:?}");
        }

        room
    }
}

#[derive(Copy, Clone, Debug, Default, Deserialize, Serialize, PartialEq, SignalPiece)]
pub struct UnreadNotificationsCount {
    /// The number of unread notifications for this room with the highlight flag
    /// set.
    pub highlight_count: u64,

    /// The total number of unread notifications for this room.
    pub notification_count: u64,
}

impl From<SdkUnreadNotificationsCount> for UnreadNotificationsCount {
    fn from(value: SdkUnreadNotificationsCount) -> Self {
        Self {
            highlight_count: value.highlight_count,
            notification_count: value.notification_count,
        }
    }
}

