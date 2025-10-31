#![allow(dead_code, clippy::large_enum_variant)]

use std::{collections::HashMap, sync::Arc};

use matrix_sdk_ui::timeline::{
    EncryptedMessage as SdkEncryptedMessage, EventTimelineItem as SdkEventTimelineItem,
    InReplyToDetails as SdkInReplyToDetails, MemberProfileChange as SdkMemberProfileChange,
    MembershipChange as SdkMembershipChange, Message as SdkMessage,
    MsgLikeContent as SdkMsgLikeContent, MsgLikeKind as SdkMsgLikeKind,
    OtherState as SdkOtherState, PollState as SdkPollState, Profile as SdkProfile,
    ReactionInfo as SdkReactionInfo, ReactionsByKeyBySender as SdkReactionsByKeyBySender,
    RoomMembershipChange as SdkRoomMembershipChange, Sticker as SdkSticker,
    ThreadSummary as SdkThreadSummary, TimelineDetails, TimelineItem as SdkTimelineItem,
    TimelineItemContent as SdkTimelineItemContent, TimelineItemKind as SdkTimelineItemKind,
    VirtualTimelineItem as SdkVirtualTimelineItem,
};
use rinf::SignalPiece;
use serde::Serialize;

use crate::matrix::{
    error::Error,
    ruma::{Mentions, MessageLikeEventType, MessageType, StateEventType, StickerEventContent},
};

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct TimelineItem {
    pub kind: TimelineItemKind,
    pub internal_id: String,
}

impl From<Arc<SdkTimelineItem>> for TimelineItem {
    fn from(value: Arc<SdkTimelineItem>) -> Self {
        Self {
            kind: value.kind().clone().into(),
            internal_id: value.unique_id().0.clone(),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum TimelineItemKind {
    /// An event or aggregation of multiple events.
    Event(EventTimelineItem),
    /// An item that doesn't correspond to an event, for example the user's
    /// own read marker, or a date divider.
    Virtual(VirtualTimelineItem),
}

impl From<SdkTimelineItemKind> for TimelineItemKind {
    fn from(value: SdkTimelineItemKind) -> Self {
        match value {
            SdkTimelineItemKind::Event(event_timeline_item) => {
                Self::Event(event_timeline_item.into())
            }
            SdkTimelineItemKind::Virtual(virtual_timeline_item) => {
                Self::Virtual(virtual_timeline_item.into())
            }
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct EventTimelineItem {
    /// The sender of the event.
    pub sender: String,
    /// The sender's profile of the event.
    pub sender_profile: TimelineDetailsProfile,
    /// The timestamp of the event.
    pub timestamp: u64,
    /// The content of the event.
    pub content: TimelineItemContent,
    /// The kind of event timeline item, local or remote.
    // pub kind: EventTimelineItemKind,
    /// Whether or not the event belongs to an encrypted room.
    ///
    /// May be false when we don't know about the room encryption status yet.
    pub is_room_encrypted: bool,
}

impl From<SdkEventTimelineItem> for EventTimelineItem {
    fn from(value: SdkEventTimelineItem) -> Self {
        Self {
            sender: value.sender().to_string(),
            sender_profile: value.sender_profile().clone().into(),
            timestamp: value.timestamp().get().into(),
            content: value.content().clone().into(),
            // TODO:
            is_room_encrypted: false,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum VirtualTimelineItem {
    /// A divider between messages of two days or months depending on the
    /// timeline configuration.
    ///
    /// The value is a timestamp in milliseconds since Unix Epoch on the given
    /// day in local time.
    DateDivider(u64),

    /// The user's own read marker.
    ReadMarker,

    /// The timeline start, that is, an indication that we've seen all the
    /// events for that timeline.
    TimelineStart,
}

impl From<SdkVirtualTimelineItem> for VirtualTimelineItem {
    fn from(value: SdkVirtualTimelineItem) -> Self {
        match value {
            SdkVirtualTimelineItem::DateDivider(milli_seconds_since_unix_epoch) => {
                Self::DateDivider(milli_seconds_since_unix_epoch.get().into())
            }
            SdkVirtualTimelineItem::ReadMarker => Self::ReadMarker,
            SdkVirtualTimelineItem::TimelineStart => Self::TimelineStart,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum TimelineDetailsProfile {
    /// The details are not available yet, and have not been requested from the
    /// server.
    Unavailable,

    /// The details are not available yet, but have been requested.
    Pending,

    /// The details are available.
    Ready(Profile),

    /// An error occurred when fetching the details.
    Error(Error),
}

impl From<TimelineDetails<SdkProfile>> for TimelineDetailsProfile {
    fn from(value: TimelineDetails<SdkProfile>) -> Self {
        match value {
            TimelineDetails::Unavailable => Self::Unavailable,
            TimelineDetails::Pending => Self::Pending,
            TimelineDetails::Ready(profile) => Self::Ready(profile.into()),
            TimelineDetails::Error(error) => Self::Error(error.into()),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct Profile {
    /// The display name, if set.
    pub display_name: Option<String>,

    /// Whether the display name is ambiguous.
    ///
    /// Note that in rooms with lazy-loading enabled, this could be `false` even
    /// though the display name is actually ambiguous if not all member events
    /// have been seen yet.
    pub display_name_ambiguous: bool,

    /// The avatar URL, if set.
    pub avatar_url: Option<String>,
}

impl From<SdkProfile> for Profile {
    fn from(value: SdkProfile) -> Self {
        Self {
            display_name: value.display_name,
            display_name_ambiguous: value.display_name_ambiguous,
            avatar_url: value.avatar_url.map(|avatar_url| avatar_url.to_string()),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum TimelineItemContent {
    MsgLike(MsgLikeContent),

    /// A room membership change.
    MembershipChange(RoomMembershipChange),

    /// A room member profile change.
    ProfileChange(MemberProfileChange),

    /// Another state event.
    OtherState(OtherState),

    /// A message-like event that failed to deserialize.
    FailedToParseMessageLike {
        /// The event `type`.
        event_type: MessageLikeEventType,

        /// The deserialization error.
        error: Error,
    },

    /// A state event that failed to deserialize.
    FailedToParseState {
        /// The event `type`.
        event_type: StateEventType,

        /// The state key.
        state_key: String,

        /// The deserialization error.
        error: Error,
    },

    /// An `m.call.invite` event
    CallInvite,

    /// An `m.call.notify` event
    CallNotify,
}

impl From<SdkTimelineItemContent> for TimelineItemContent {
    fn from(value: SdkTimelineItemContent) -> Self {
        match value {
            SdkTimelineItemContent::MsgLike(msg_like_content) => {
                Self::MsgLike(msg_like_content.into())
            }
            SdkTimelineItemContent::MembershipChange(room_membership_change) => {
                Self::MembershipChange(room_membership_change.into())
            }
            SdkTimelineItemContent::ProfileChange(member_profile_change) => {
                Self::ProfileChange(member_profile_change.into())
            }
            SdkTimelineItemContent::OtherState(other_state) => Self::OtherState(other_state.into()),
            SdkTimelineItemContent::FailedToParseMessageLike { event_type, error } => {
                Self::FailedToParseMessageLike {
                    event_type: event_type.into(),
                    error: Error::SerdeJson(error.to_string()),
                }
            }
            SdkTimelineItemContent::FailedToParseState {
                event_type,
                state_key,
                error,
            } => Self::FailedToParseState {
                event_type: event_type.into(),
                state_key,
                error: Error::SerdeJson(error.to_string()),
            },
            SdkTimelineItemContent::CallInvite => Self::CallInvite,
            SdkTimelineItemContent::CallNotify => Self::CallNotify,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct MsgLikeContent {
    pub kind: MsgLikeKind,
    pub reactions: ReactionsByKeyBySender,
    /// The event this message is replying to, if any.
    pub in_reply_to: Option<InReplyToDetails>,
    /// Event ID of the thread root, if this is a message in a thread.
    pub thread_root: Option<String>,
    /// Information about the thread this message is the root of, if any.
    pub thread_summary: Option<ThreadSummary>,
}

impl From<SdkMsgLikeContent> for MsgLikeContent {
    fn from(value: SdkMsgLikeContent) -> Self {
        Self {
            kind: value.kind.into(),
            reactions: value.reactions.into(),
            in_reply_to: value.in_reply_to.map(Into::into),
            thread_root: value.thread_root.map(Into::into),
            thread_summary: value.thread_summary.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct RoomMembershipChange {
    pub user_id: String,
    // pub content: FullStateEventContent<RoomMemberEventContent>,
    pub change: Option<MembershipChange>,
}

impl From<SdkRoomMembershipChange> for RoomMembershipChange {
    fn from(value: SdkRoomMembershipChange) -> Self {
        Self {
            user_id: value.user_id().to_string(),
            change: value.change().map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct MemberProfileChange {
    pub user_id: String,
    // pub displayname_change: Option<Change<Option<String>>>,
    // pub avatar_url_change: Option<Change<Option<String>>>,
}

impl From<SdkMemberProfileChange> for MemberProfileChange {
    fn from(value: SdkMemberProfileChange) -> Self {
        Self {
            user_id: value.user_id().to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct OtherState {
    pub state_key: String,
    // pub content: AnyOtherFullStateEventContent,
}

impl From<SdkOtherState> for OtherState {
    fn from(value: SdkOtherState) -> Self {
        Self {
            state_key: value.state_key().to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum MsgLikeKind {
    /// An `m.room.message` event or extensible event, including edits.
    Message(Message),

    /// An `m.sticker` event.
    Sticker(Sticker),

    /// An `m.poll.start` event.
    Poll(PollState),

    /// A redacted message.
    Redacted,

    /// An `m.room.encrypted` event that could not be decrypted.
    UnableToDecrypt(EncryptedMessage),
}

impl From<SdkMsgLikeKind> for MsgLikeKind {
    fn from(value: SdkMsgLikeKind) -> Self {
        match value {
            SdkMsgLikeKind::Message(message) => Self::Message(message.into()),
            SdkMsgLikeKind::Sticker(sticker) => Self::Sticker(sticker.into()),
            SdkMsgLikeKind::Poll(poll_state) => Self::Poll(poll_state.into()),
            SdkMsgLikeKind::Redacted => Self::Redacted,
            SdkMsgLikeKind::UnableToDecrypt(encrypted_message) => {
                Self::UnableToDecrypt(encrypted_message.into())
            }
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct Message {
    pub msgtype: MessageType,
    pub edited: bool,
    pub mentions: Option<Mentions>,
}

impl From<SdkMessage> for Message {
    fn from(value: SdkMessage) -> Self {
        Self {
            msgtype: value.msgtype().clone().into(),
            edited: value.is_edited(),
            mentions: value.mentions().cloned().map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct Sticker {
    pub content: StickerEventContent,
}

impl From<SdkSticker> for Sticker {
    fn from(value: SdkSticker) -> Self {
        Self {
            content: value.content().clone().into(),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct PollState;

impl From<SdkPollState> for PollState {
    fn from(_value: SdkPollState) -> Self {
        Self
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct EncryptedMessage;

impl From<SdkEncryptedMessage> for EncryptedMessage {
    fn from(_value: SdkEncryptedMessage) -> Self {
        Self
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct ReactionsByKeyBySender(HashMap<String, HashMap<String, ReactionInfo>>);

impl From<SdkReactionsByKeyBySender> for ReactionsByKeyBySender {
    fn from(value: SdkReactionsByKeyBySender) -> Self {
        Self(
            value
                .iter()
                .map(|(k, v)| {
                    (
                        k.into(),
                        v.into_iter()
                            .map(|(k, v)| (k.clone().into(), v.clone().into()))
                            .collect(),
                    )
                })
                .collect(),
        )
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct InReplyToDetails {
    /// The ID of the event.
    pub event_id: String,
    // /// The details of the event.
    // ///
    // /// Use [`Timeline::fetch_details_for_event`] to fetch the data if it is
    // /// unavailable.
    // ///
    // /// [`Timeline::fetch_details_for_event`]: crate::Timeline::fetch_details_for_event
    // pub event: TimelineDetails<Box<EmbeddedEvent>>,
}

impl From<SdkInReplyToDetails> for InReplyToDetails {
    fn from(value: SdkInReplyToDetails) -> Self {
        Self {
            event_id: value.event_id.to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct ThreadSummary {
    /// The number of events in the thread, except for the thread root.
    ///
    /// This can be zero if all the events in the thread have been redacted.
    ///
    /// Note: this doesn't interact with the timeline filter; so opening a
    /// thread-focused timeline with the same timeline filter may result in
    /// *fewer* events than this number.
    pub num_replies: u32,
}

impl From<SdkThreadSummary> for ThreadSummary {
    fn from(value: SdkThreadSummary) -> Self {
        Self {
            num_replies: value.num_replies,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum MembershipChange {
    /// No change.
    None,

    /// Must never happen.
    Error,

    /// User joined the room.
    Joined,

    /// User left the room.
    Left,

    /// User was banned.
    Banned,

    /// User was unbanned.
    Unbanned,

    /// User was kicked.
    Kicked,

    /// User was invited.
    Invited,

    /// User was kicked and banned.
    KickedAndBanned,

    /// User accepted the invite.
    InvitationAccepted,

    /// User rejected the invite.
    InvitationRejected,

    /// User had their invite revoked.
    InvitationRevoked,

    /// User knocked.
    Knocked,

    /// User had their knock accepted.
    KnockAccepted,

    /// User retracted their knock.
    KnockRetracted,

    /// User had their knock denied.
    KnockDenied,

    /// Not implemented.
    NotImplemented,
}

impl From<SdkMembershipChange> for MembershipChange {
    fn from(value: SdkMembershipChange) -> Self {
        match value {
            SdkMembershipChange::None => Self::None,
            SdkMembershipChange::Error => Self::Error,
            SdkMembershipChange::Joined => Self::Joined,
            SdkMembershipChange::Left => Self::Left,
            SdkMembershipChange::Banned => Self::Banned,
            SdkMembershipChange::Unbanned => Self::Unbanned,
            SdkMembershipChange::Kicked => Self::Kicked,
            SdkMembershipChange::Invited => Self::Invited,
            SdkMembershipChange::KickedAndBanned => Self::KickedAndBanned,
            SdkMembershipChange::InvitationAccepted => Self::InvitationAccepted,
            SdkMembershipChange::InvitationRejected => Self::InvitationRejected,
            SdkMembershipChange::InvitationRevoked => Self::InvitationRevoked,
            SdkMembershipChange::Knocked => Self::Knocked,
            SdkMembershipChange::KnockAccepted => Self::KnockAccepted,
            SdkMembershipChange::KnockRetracted => Self::KnockRetracted,
            SdkMembershipChange::KnockDenied => Self::KnockDenied,
            SdkMembershipChange::NotImplemented => Self::NotImplemented,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct ReactionInfo {
    pub timestamp: u64,
}

impl From<SdkReactionInfo> for ReactionInfo {
    fn from(value: SdkReactionInfo) -> Self {
        Self {
            timestamp: value.timestamp.get().into(),
        }
    }
}
