use std::sync::Arc;

use matrix_sdk::{
    deserialized_responses::{TimelineEvent, TimelineEventKind},
    room::MessagesOptions,
    EncryptionState, Room, RoomState,
};
use rinf::SignalPiece;
use ruma::{
    api::Direction,
    events::{
        room::message::{MessageType, RoomMessageEventContent},
        AnyMessageLikeEvent, AnyTimelineEvent, MessageLikeEvent,
    },
    OwnedRoomId,
};
use serde::Serialize;
use tracing::warn;

use crate::{
    client::JoinRule,
    error::ClientError,
    notification_settings::RoomNotificationMode,
    room::{
        power_levels::RoomPowerLevels, Membership, RoomHero, RoomHistoryVisibility, SuccessorRoom,
    },
    room_member::RoomMember,
};

#[derive(Serialize, SignalPiece, Debug)]
pub struct RoomInfo {
    pub id: String,
    #[serde(skip)]
    pub encryption_state: EncryptionState,
    pub creator: Option<String>,
    /// The room's name from the room state event if received from sync, or one
    /// that's been computed otherwise.
    pub display_name: Option<String>,
    /// Room name as defined by the room state event only.
    pub raw_name: Option<String>,
    pub topic: Option<String>,
    pub avatar_url: Option<String>,
    pub is_direct: bool,
    /// Whether the room is public or not, based on the join rules.
    ///
    /// Can be `None` if the join rules state event is not available for this
    /// room.
    pub is_public: Option<bool>,
    pub is_space: bool,
    /// If present, it means the room has been archived/upgraded.
    pub successor_room: Option<SuccessorRoom>,
    pub is_favourite: bool,
    pub canonical_alias: Option<String>,
    pub alternative_aliases: Vec<String>,
    pub membership: Membership,
    /// Member who invited the current user to a room that's in the invited
    /// state.
    ///
    /// Can be missing if the room membership invite event is missing from the
    /// store.
    pub inviter: Option<RoomMember>,
    pub heroes: Vec<RoomHero>,
    pub active_members_count: u64,
    pub invited_members_count: u64,
    pub joined_members_count: u64,
    pub highlight_count: u64,
    pub notification_count: u64,
    pub cached_user_defined_notification_mode: Option<RoomNotificationMode>,
    pub has_room_call: bool,
    pub active_room_call_participants: Vec<String>,
    /// Whether this room has been explicitly marked as unread
    pub is_marked_unread: bool,
    /// "Interesting" messages received in that room, independently of the
    /// notification settings.
    pub num_unread_messages: u64,
    /// Events that will notify the user, according to their
    /// notification settings.
    pub num_unread_notifications: u64,
    /// Events causing mentions/highlights for the user, according to their
    /// notification settings.
    pub num_unread_mentions: u64,
    /// The currently pinned event ids.
    pub pinned_event_ids: Vec<String>,
    /// The join rule for this room, if known.
    pub join_rule: Option<JoinRule>,
    /// The history visibility for this room, if known.
    pub history_visibility: RoomHistoryVisibility,

    pub last_message: Option<String>,

    /// This room's current power levels.
    ///
    /// Can be missing if the room power levels event is missing from the store.
    #[serde(skip)]
    pub power_levels: Option<Arc<RoomPowerLevels>>,
}

impl RoomInfo {
    pub async fn new(room: &Room) -> Result<Self, ClientError> {
        let unread_notification_counts = room.unread_notification_counts();

        let pinned_event_ids = room
            .pinned_event_ids()
            .unwrap_or_default()
            .iter()
            .map(|id| id.to_string())
            .collect();

        let join_rule = room
            .join_rule()
            .map(TryInto::try_into)
            .transpose()
            .inspect_err(|err| {
                warn!("Failed to parse join rule: {err}");
            })
            .ok()
            .flatten();

        let power_levels = room
            .power_levels()
            .await
            .ok()
            .map(|p| RoomPowerLevels::new(p, room.own_user_id().to_owned()));

        // https://github.com/pkulak/matui/blob/d067a23fb1b693dc5ab14db6c4641bde6c194891/src/matrix/roomcache.rs#L170
        let last_message = RoomInfo::get_last_message(room).await;

        Ok(Self {
            id: room.room_id().to_string(),
            encryption_state: room.encryption_state(),
            creator: room.creator().as_ref().map(ToString::to_string),
            display_name: room.cached_display_name().map(|name| name.to_string()),
            raw_name: room.name(),
            topic: room.topic(),
            avatar_url: room.avatar_url().map(Into::into),
            is_direct: room.is_direct().await?,
            is_public: room.is_public(),
            is_space: room.is_space(),
            successor_room: room.successor_room().map(Into::into),
            is_favourite: room.is_favourite(),
            canonical_alias: room.canonical_alias().map(Into::into),
            alternative_aliases: room.alt_aliases().into_iter().map(Into::into).collect(),
            membership: room.state().into(),
            inviter: match room.state() {
                RoomState::Invited => room
                    .invite_details()
                    .await
                    .ok()
                    .and_then(|details| details.inviter)
                    .map(TryInto::try_into)
                    .transpose()
                    .ok()
                    .flatten(),
                _ => None,
            },
            heroes: room.heroes().into_iter().map(Into::into).collect(),
            active_members_count: room.active_members_count(),
            invited_members_count: room.invited_members_count(),
            joined_members_count: room.joined_members_count(),
            highlight_count: unread_notification_counts.highlight_count,
            notification_count: unread_notification_counts.notification_count,
            cached_user_defined_notification_mode: room
                .cached_user_defined_notification_mode()
                .map(Into::into),
            has_room_call: room.has_active_room_call(),
            active_room_call_participants: room
                .active_room_call_participants()
                .iter()
                .map(|u| u.to_string())
                .collect(),
            is_marked_unread: room.is_marked_unread(),
            num_unread_messages: room.num_unread_messages(),
            num_unread_notifications: room.num_unread_notifications(),
            num_unread_mentions: room.num_unread_mentions(),
            pinned_event_ids,
            join_rule,
            history_visibility: room.history_visibility_or_default().try_into()?,
            power_levels: power_levels.map(Arc::new),
            last_message,
        })
    }

    fn deserialize_event(
        event: &TimelineEvent,
        room_id: OwnedRoomId,
    ) -> anyhow::Result<AnyTimelineEvent> {
        match &event.kind {
            TimelineEventKind::Decrypted(decrypted) => Ok(decrypted.event.deserialize()?.into()),
            TimelineEventKind::PlainText { event } => {
                Ok(event.deserialize()?.into_full_event(room_id))
            }
            TimelineEventKind::UnableToDecrypt { event, .. } => {
                Ok(event.deserialize()?.into_full_event(room_id))
            }
        }
    }
    pub fn get_room_message_event(
        room: &Room,
        event: &TimelineEvent,
    ) -> Option<MessageLikeEvent<RoomMessageEventContent>> {
        let Ok(event) = RoomInfo::deserialize_event(event, room.room_id().to_owned()) else {
            return None;
        };

        let AnyTimelineEvent::MessageLike(AnyMessageLikeEvent::RoomMessage(event)) = event else {
            return None;
        };

        Some(event)
    }

    async fn get_last_message(room: &Room) -> Option<String> {
        let events = room
            .messages(MessagesOptions::new(Direction::Backward))
            .await
            .ok()?
            .chunk;

        for e in &events {
            let Some(event) = RoomInfo::get_room_message_event(room, e) else {
                continue;
            };

            let (body, _og) = if let Some(og) = event.as_original() {
                if let MessageType::Text(content) = &og.content.msgtype {
                    (content.body.clone(), og)
                } else {
                    ("".to_string(), og)
                }
            } else {
                continue;
            };

            return Some(body);
        }

        None
    }
}
