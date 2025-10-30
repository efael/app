#![allow(dead_code)]

use rinf::SignalPiece;
use ruma::events::{
    Mentions as SdkMentions, MessageLikeEventType as SdkMessageLikeEventType,
    StateEventType as SdkStateEventType,
    key::verification::VerificationMethod as SdkVerificationMethod,
    room::{
        EncryptedFile as SdkEncryptedFile, ImageInfo as SdkImageInfo,
        MediaSource as SdkMediaSource, ThumbnailInfo as SdkThumbnailInfo,
        message::{
            AudioInfo as SdkAudioInfo, AudioMessageEventContent as SdkAudioMessageEventContent,
            EmoteMessageEventContent as SdkEmoteMessageEventContent, FileInfo as SdkFileInfo,
            FileMessageEventContent as SdkFileMessageEventContent,
            FormattedBody as SdkFormattedBody,
            ImageMessageEventContent as SdkImageMessageEventContent,
            KeyVerificationRequestEventContent as SdkKeyVerificationRequestEventContent,
            LimitType as SdkLimitType, LocationInfo as SdkLocationInfo,
            LocationMessageEventContent as SdkLocationMessageEventContent,
            MessageFormat as SdkMessageFormat, MessageType as SdkMessageType,
            NoticeMessageEventContent as SdkNoticeMessageEventContent,
            ServerNoticeMessageEventContent as SdkServerNoticeMessageEventContent,
            ServerNoticeType as SdkServerNoticeType,
            TextMessageEventContent as SdkTextMessageEventContent, VideoInfo as SdkVideoInfo,
            VideoMessageEventContent as SdkVideoMessageEventContent,
        },
    },
    sticker::{
        StickerEventContent as SdkStickerEventContent, StickerMediaSource as SdkStickerMediaSource,
    },
};

use serde::Serialize;

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum MessageLikeEventType {
    CallAnswer,
    CallInvite,
    CallHangup,
    CallCandidates,
    CallNegotiate,
    CallReject,
    CallSdpStreamMetadataChanged,
    CallSelectAnswer,
    KeyVerificationReady,
    KeyVerificationStart,
    KeyVerificationCancel,
    KeyVerificationAccept,
    KeyVerificationKey,
    KeyVerificationMac,
    KeyVerificationDone,
    Location,
    Message,
    PollStart,
    UnstablePollStart,
    PollResponse,
    UnstablePollResponse,
    PollEnd,
    UnstablePollEnd,
    Beacon,
    Reaction,
    RoomEncrypted,
    RoomMessage,
    RoomRedaction,
    Sticker,
    CallNotify,
    Unknown,
}

impl From<SdkMessageLikeEventType> for MessageLikeEventType {
    fn from(value: SdkMessageLikeEventType) -> Self {
        match value {
            SdkMessageLikeEventType::CallAnswer => Self::CallAnswer,
            SdkMessageLikeEventType::CallInvite => Self::CallInvite,
            SdkMessageLikeEventType::CallHangup => Self::CallHangup,
            SdkMessageLikeEventType::CallCandidates => Self::CallCandidates,
            SdkMessageLikeEventType::CallNegotiate => Self::CallNegotiate,
            SdkMessageLikeEventType::CallReject => Self::CallReject,
            SdkMessageLikeEventType::CallSdpStreamMetadataChanged => {
                Self::CallSdpStreamMetadataChanged
            }
            SdkMessageLikeEventType::CallSelectAnswer => Self::CallSelectAnswer,
            SdkMessageLikeEventType::KeyVerificationReady => Self::KeyVerificationReady,
            SdkMessageLikeEventType::KeyVerificationStart => Self::KeyVerificationStart,
            SdkMessageLikeEventType::KeyVerificationCancel => Self::KeyVerificationCancel,
            SdkMessageLikeEventType::KeyVerificationAccept => Self::KeyVerificationAccept,
            SdkMessageLikeEventType::KeyVerificationKey => Self::KeyVerificationKey,
            SdkMessageLikeEventType::KeyVerificationMac => Self::KeyVerificationMac,
            SdkMessageLikeEventType::KeyVerificationDone => Self::KeyVerificationDone,
            SdkMessageLikeEventType::Location => Self::Location,
            SdkMessageLikeEventType::Message => Self::Message,
            SdkMessageLikeEventType::PollStart => Self::PollStart,
            SdkMessageLikeEventType::UnstablePollStart => Self::UnstablePollStart,
            SdkMessageLikeEventType::PollResponse => Self::PollResponse,
            SdkMessageLikeEventType::UnstablePollResponse => Self::UnstablePollResponse,
            SdkMessageLikeEventType::PollEnd => Self::PollEnd,
            SdkMessageLikeEventType::UnstablePollEnd => Self::UnstablePollEnd,
            SdkMessageLikeEventType::Beacon => Self::Beacon,
            SdkMessageLikeEventType::Reaction => Self::Reaction,
            SdkMessageLikeEventType::RoomEncrypted => Self::RoomEncrypted,
            SdkMessageLikeEventType::RoomMessage => Self::RoomMessage,
            SdkMessageLikeEventType::RoomRedaction => Self::RoomRedaction,
            SdkMessageLikeEventType::Sticker => Self::Sticker,
            SdkMessageLikeEventType::CallNotify => Self::CallNotify,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum StateEventType {
    PolicyRuleRoom,
    PolicyRuleServer,
    PolicyRuleUser,
    RoomAliases,
    RoomAvatar,
    RoomCanonicalAlias,
    RoomCreate,
    RoomEncryption,
    RoomGuestAccess,
    RoomHistoryVisibility,
    RoomJoinRules,
    RoomMember,
    RoomName,
    RoomPinnedEvents,
    RoomPowerLevels,
    RoomServerAcl,
    RoomThirdPartyInvite,
    RoomTombstone,
    RoomTopic,
    SpaceChild,
    SpaceParent,
    BeaconInfo,
    CallMember,
    MemberHints,
    Unknown,
}

impl From<SdkStateEventType> for StateEventType {
    fn from(value: SdkStateEventType) -> Self {
        match value {
            SdkStateEventType::PolicyRuleRoom => Self::PolicyRuleRoom,
            SdkStateEventType::PolicyRuleServer => Self::PolicyRuleServer,
            SdkStateEventType::PolicyRuleUser => Self::PolicyRuleUser,
            SdkStateEventType::RoomAliases => Self::RoomAliases,
            SdkStateEventType::RoomAvatar => Self::RoomAvatar,
            SdkStateEventType::RoomCanonicalAlias => Self::RoomCanonicalAlias,
            SdkStateEventType::RoomCreate => Self::RoomCreate,
            SdkStateEventType::RoomEncryption => Self::RoomEncryption,
            SdkStateEventType::RoomGuestAccess => Self::RoomGuestAccess,
            SdkStateEventType::RoomHistoryVisibility => Self::RoomHistoryVisibility,
            SdkStateEventType::RoomJoinRules => Self::RoomJoinRules,
            SdkStateEventType::RoomMember => Self::RoomMember,
            SdkStateEventType::RoomName => Self::RoomName,
            SdkStateEventType::RoomPinnedEvents => Self::RoomPinnedEvents,
            SdkStateEventType::RoomPowerLevels => Self::RoomPowerLevels,
            SdkStateEventType::RoomServerAcl => Self::RoomServerAcl,
            SdkStateEventType::RoomThirdPartyInvite => Self::RoomThirdPartyInvite,
            SdkStateEventType::RoomTombstone => Self::RoomTombstone,
            SdkStateEventType::RoomTopic => Self::RoomTopic,
            SdkStateEventType::SpaceChild => Self::SpaceChild,
            SdkStateEventType::SpaceParent => Self::SpaceParent,
            SdkStateEventType::BeaconInfo => Self::BeaconInfo,
            SdkStateEventType::CallMember => Self::CallMember,
            SdkStateEventType::MemberHints => Self::MemberHints,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum MessageType {
    /// An audio message.
    Audio(AudioMessageEventContent),

    /// An emote message.
    Emote(EmoteMessageEventContent),

    /// A file message.
    File(FileMessageEventContent),

    // /// A media gallery message.
    // Gallery(GalleryMessageEventContent),
    //
    /// An image message.
    Image(ImageMessageEventContent),

    /// A location message.
    Location(LocationMessageEventContent),

    /// A notice message.
    Notice(NoticeMessageEventContent),

    /// A server notice message.
    ServerNotice(ServerNoticeMessageEventContent),

    /// A text message.
    Text(TextMessageEventContent),

    /// A video message.
    Video(VideoMessageEventContent),

    /// A request to initiate a key verification.
    VerificationRequest(KeyVerificationRequestEventContent),
    //
    // /// A custom message.
    // _Custom(CustomEventContent),
    Unknown,
}

impl From<SdkMessageType> for MessageType {
    fn from(value: SdkMessageType) -> Self {
        match value {
            SdkMessageType::Audio(audio_message_event_content) => {
                Self::Audio(audio_message_event_content.into())
            }
            SdkMessageType::Emote(emote_message_event_content) => {
                Self::Emote(emote_message_event_content.into())
            }
            SdkMessageType::File(file_message_event_content) => {
                Self::File(file_message_event_content.into())
            }
            SdkMessageType::Image(image_message_event_content) => {
                Self::Image(image_message_event_content.into())
            }
            SdkMessageType::Location(location_message_event_content) => {
                Self::Location(location_message_event_content.into())
            }
            SdkMessageType::Notice(notice_message_event_content) => {
                Self::Notice(notice_message_event_content.into())
            }
            SdkMessageType::ServerNotice(server_notice_message_event_content) => {
                Self::ServerNotice(server_notice_message_event_content.into())
            }
            SdkMessageType::Text(text_message_event_content) => {
                Self::Text(text_message_event_content.into())
            }
            SdkMessageType::Video(video_message_event_content) => {
                Self::Video(video_message_event_content.into())
            }
            SdkMessageType::VerificationRequest(key_verification_request_event_content) => {
                Self::VerificationRequest(key_verification_request_event_content.into())
            }
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct Mentions {
    /// The list of mentioned users.
    ///
    /// Defaults to an empty `BTreeSet`.
    pub user_ids: Vec<String>,

    /// Whether the whole room is mentioned.
    ///
    /// Defaults to `false`.
    pub room: bool,
}

impl From<SdkMentions> for Mentions {
    fn from(value: SdkMentions) -> Self {
        Self {
            user_ids: value.user_ids.into_iter().map(Into::into).collect(),
            room: value.room,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct AudioMessageEventContent {
    /// The textual representation of this message.
    ///
    /// If the `filename` field is not set or has the same value, this is the filename of the
    /// uploaded file. Otherwise, this should be interpreted as a user-written media caption.
    pub body: String,

    /// Formatted form of the message `body`.
    ///
    /// This should only be set if the body represents a caption.
    pub formatted: Option<FormattedBody>,

    /// The original filename of the uploaded file as deserialized from the event.
    ///
    /// It is recommended to use the `filename` method to get the filename which automatically
    /// falls back to the `body` field when the `filename` field is not set.
    pub filename: Option<String>,

    /// The source of the audio clip.
    pub source: MediaSource,

    /// Metadata for the audio clip referred to in `source`.
    pub info: Option<AudioInfo>,
}

impl From<SdkAudioMessageEventContent> for AudioMessageEventContent {
    fn from(value: SdkAudioMessageEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
            filename: value.filename,
            source: value.source.into(),
            info: value.info.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct EmoteMessageEventContent {
    /// The emote action to perform.
    pub body: String,

    /// Formatted form of the message `body`.
    pub formatted: Option<FormattedBody>,
}

impl From<SdkEmoteMessageEventContent> for EmoteMessageEventContent {
    fn from(value: SdkEmoteMessageEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct FileMessageEventContent {
    /// A human-readable description of the file.
    ///
    /// If the `filename` field is not set or has the same value, this is the filename of the
    /// uploaded file. Otherwise, this should be interpreted as a user-written media caption.
    pub body: String,

    /// Formatted form of the message `body`.
    ///
    /// This should only be set if the body represents a caption.
    pub formatted: Option<FormattedBody>,

    /// The original filename of the uploaded file as deserialized from the event.
    ///
    /// It is recommended to use the `filename` method to get the filename which automatically
    /// falls back to the `body` field when the `filename` field is not set.
    pub filename: Option<String>,

    /// The source of the file.
    pub source: MediaSource,

    /// Metadata about the file referred to in `source`.
    pub info: Option<FileInfo>,
}

impl From<SdkFileMessageEventContent> for FileMessageEventContent {
    fn from(value: SdkFileMessageEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
            filename: value.filename,
            source: value.source.into(),
            info: value.info.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct ImageMessageEventContent {
    /// A textual representation of the image.
    ///
    /// If the `filename` field is not set or has the same value, this is the filename of the
    /// uploaded file. Otherwise, this should be interpreted as a user-written media caption.
    pub body: String,

    /// Formatted form of the message `body`.
    ///
    /// This should only be set if the body represents a caption.
    pub formatted: Option<FormattedBody>,

    /// The original filename of the uploaded file as deserialized from the event.
    ///
    /// It is recommended to use the `filename` method to get the filename which automatically
    /// falls back to the `body` field when the `filename` field is not set.
    pub filename: Option<String>,

    /// The source of the image.
    pub source: MediaSource,

    /// Metadata about the image referred to in `source`.
    pub info: Option<ImageInfo>,
}

impl From<SdkImageMessageEventContent> for ImageMessageEventContent {
    fn from(value: SdkImageMessageEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
            filename: value.filename,
            source: value.source.into(),
            info: value.info.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct LocationMessageEventContent {
    /// A description of the location e.g. "Big Ben, London, UK", or some kind of content
    /// description for accessibility, e.g. "location attachment".
    pub body: String,

    /// A geo URI representing the location.
    pub geo_uri: String,

    /// Info about the location being represented.
    pub info: Option<LocationInfo>,
}

impl From<SdkLocationMessageEventContent> for LocationMessageEventContent {
    fn from(value: SdkLocationMessageEventContent) -> Self {
        Self {
            body: value.body,
            geo_uri: value.geo_uri,
            info: value.info.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct NoticeMessageEventContent {
    /// The notice text.
    pub body: String,

    /// Formatted form of the message `body`.
    pub formatted: Option<FormattedBody>,
}

impl From<SdkNoticeMessageEventContent> for NoticeMessageEventContent {
    fn from(value: SdkNoticeMessageEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct ServerNoticeMessageEventContent {
    /// A human-readable description of the notice.
    pub body: String,

    /// The type of notice being represented.
    pub server_notice_type: ServerNoticeType,

    /// A URI giving a contact method for the server administrator.
    ///
    /// Required if the notice type is `m.server_notice.usage_limit_reached`.
    pub admin_contact: Option<String>,

    /// The kind of usage limit the server has exceeded.
    ///
    /// Required if the notice type is `m.server_notice.usage_limit_reached`.
    pub limit_type: Option<LimitType>,
}

impl From<SdkServerNoticeMessageEventContent> for ServerNoticeMessageEventContent {
    fn from(value: SdkServerNoticeMessageEventContent) -> Self {
        Self {
            body: value.body,
            server_notice_type: value.server_notice_type.into(),
            admin_contact: value.admin_contact,
            limit_type: value.limit_type.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct TextMessageEventContent {
    /// The body of the message.
    pub body: String,

    /// Formatted form of the message `body`.
    pub formatted: Option<FormattedBody>,
}

impl From<SdkTextMessageEventContent> for TextMessageEventContent {
    fn from(value: SdkTextMessageEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct VideoMessageEventContent {
    /// A description of the video.
    ///
    /// If the `filename` field is not set or has the same value, this is the filename of the
    /// uploaded file. Otherwise, this should be interpreted as a user-written media caption.
    pub body: String,

    /// Formatted form of the message `body`.
    ///
    /// This should only be set if the body represents a caption.
    pub formatted: Option<FormattedBody>,

    /// The original filename of the uploaded file as deserialized from the event.
    ///
    /// It is recommended to use the `filename` method to get the filename which automatically
    /// falls back to the `body` field when the `filename` field is not set.
    pub filename: Option<String>,

    /// The source of the video clip.
    pub source: MediaSource,

    /// Metadata about the video clip referred to in `source`.
    pub info: Option<VideoInfo>,
}

impl From<SdkVideoMessageEventContent> for VideoMessageEventContent {
    fn from(value: SdkVideoMessageEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
            filename: value.filename,
            source: value.source.into(),
            info: value.info.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct KeyVerificationRequestEventContent {
    /// A fallback message to alert users that their client does not support the key verification
    /// framework.
    ///
    /// Clients that do support the key verification framework should hide the body and instead
    /// present the user with an interface to accept or reject the key verification.
    pub body: String,

    /// Formatted form of the `body`.
    ///
    /// As with the `body`, clients that do support the key verification framework should hide the
    /// formatted body and instead present the user with an interface to accept or reject the key
    /// verification.
    pub formatted: Option<FormattedBody>,

    /// The verification methods supported by the sender.
    pub methods: Vec<VerificationMethod>,

    /// The device ID which is initiating the request.
    pub from_device: String,

    /// The user ID which should receive the request.
    ///
    /// Users should only respond to verification requests if they are named in this field. Users
    /// who are not named in this field and who did not send this event should ignore all other
    /// events that have a `m.reference` relationship with this event.
    pub to: String,
}

impl From<SdkKeyVerificationRequestEventContent> for KeyVerificationRequestEventContent {
    fn from(value: SdkKeyVerificationRequestEventContent) -> Self {
        Self {
            body: value.body,
            formatted: value.formatted.map(Into::into),
            methods: value.methods.into_iter().map(Into::into).collect(),
            from_device: value.from_device.to_string(),
            to: value.to.to_string(),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct FormattedBody {
    /// The format used in the `formatted_body`.
    pub format: MessageFormat,

    /// The formatted version of the `body`.
    pub body: String,
}

impl From<SdkFormattedBody> for FormattedBody {
    fn from(value: SdkFormattedBody) -> Self {
        Self {
            format: value.format.into(),
            body: value.body,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum MediaSource {
    /// The MXC URI to the unencrypted media file.
    Plain(String),

    /// The encryption info of the encrypted media file.
    Encrypted(EncryptedFile),
}

impl From<SdkMediaSource> for MediaSource {
    fn from(value: SdkMediaSource) -> Self {
        match value {
            SdkMediaSource::Plain(owned_mxc_uri) => Self::Plain(owned_mxc_uri.to_string()),
            SdkMediaSource::Encrypted(encrypted_file) => Self::Encrypted(encrypted_file.into()),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct AudioInfo {
    /// The duration of the audio in milliseconds.
    pub duration: Option<u128>,

    /// The mimetype of the audio, e.g. "audio/aac".
    pub mimetype: Option<String>,

    /// The size of the audio clip in bytes.
    pub size: Option<u64>,
}

impl From<Box<SdkAudioInfo>> for AudioInfo {
    fn from(value: Box<SdkAudioInfo>) -> Self {
        Self {
            duration: value.duration.map(|d| d.as_millis()),
            mimetype: value.mimetype,
            size: value.size.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct VideoInfo {
    /// The duration of the video in milliseconds.
    pub duration: Option<u128>,

    /// The height of the video in pixels.
    pub height: Option<u64>,

    /// The width of the video in pixels.
    pub width: Option<u64>,

    /// The mimetype of the video, e.g. "video/mp4".
    pub mimetype: Option<String>,

    /// The size of the video in bytes.
    pub size: Option<u64>,

    /// Metadata about the image referred to in `thumbnail_source`.
    pub thumbnail_info: Option<ThumbnailInfo>,

    /// The source of the thumbnail of the video clip.
    pub thumbnail_source: Option<MediaSource>,
}

impl From<Box<SdkVideoInfo>> for VideoInfo {
    fn from(value: Box<SdkVideoInfo>) -> Self {
        Self {
            duration: value.duration.map(|d| d.as_millis()),
            height: value.height.map(Into::into),
            width: value.width.map(Into::into),
            mimetype: value.mimetype,
            size: value.size.map(Into::into),
            thumbnail_info: value.thumbnail_info.map(Into::into),
            thumbnail_source: value.thumbnail_source.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct FileInfo {
    /// The mimetype of the file, e.g. "application/msword".
    pub mimetype: Option<String>,

    /// The size of the file in bytes.
    pub size: Option<u64>,

    /// Metadata about the image referred to in `thumbnail_source`.
    pub thumbnail_info: Option<ThumbnailInfo>,

    /// The source of the thumbnail of the file.
    pub thumbnail_source: Option<MediaSource>,
}

impl From<Box<SdkFileInfo>> for FileInfo {
    fn from(value: Box<SdkFileInfo>) -> Self {
        Self {
            mimetype: value.mimetype,
            size: value.size.map(Into::into),
            thumbnail_info: value.thumbnail_info.map(Into::into),
            thumbnail_source: value.thumbnail_source.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct ImageInfo {
    /// The height of the image in pixels.
    pub height: Option<u64>,

    /// The width of the image in pixels.
    pub width: Option<u64>,

    /// The MIME type of the image, e.g. "image/png."
    pub mimetype: Option<String>,

    /// The file size of the image in bytes.
    pub size: Option<u64>,

    /// Metadata about the image referred to in `thumbnail_source`.
    pub thumbnail_info: Option<ThumbnailInfo>,

    /// The source of the thumbnail of the image.
    pub thumbnail_source: Option<MediaSource>,
}

impl From<Box<SdkImageInfo>> for ImageInfo {
    fn from(value: Box<SdkImageInfo>) -> Self {
        Self {
            height: value.height.map(Into::into),
            width: value.width.map(Into::into),
            mimetype: value.mimetype,
            size: value.size.map(Into::into),
            thumbnail_info: value.thumbnail_info.map(Into::into),
            thumbnail_source: value.thumbnail_source.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct LocationInfo {
    /// The source of a thumbnail of the location.
    pub thumbnail_source: Option<MediaSource>,

    /// Metadata about the image referred to in `thumbnail_source.
    pub thumbnail_info: Option<ThumbnailInfo>,
}

impl From<Box<SdkLocationInfo>> for LocationInfo {
    fn from(value: Box<SdkLocationInfo>) -> Self {
        Self {
            thumbnail_source: value.thumbnail_source.map(Into::into),
            thumbnail_info: value.thumbnail_info.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum VerificationMethod {
    /// The `m.sas.v1` verification method.
    SasV1,

    /// The `m.qr_code.scan.v1` verification method.
    QrCodeScanV1,

    /// The `m.qr_code.show.v1` verification method.
    QrCodeShowV1,

    /// The `m.reciprocate.v1` verification method.
    ReciprocateV1,

    Unknown,
}

impl From<SdkVerificationMethod> for VerificationMethod {
    fn from(value: SdkVerificationMethod) -> Self {
        match value {
            SdkVerificationMethod::SasV1 => Self::SasV1,
            SdkVerificationMethod::QrCodeScanV1 => Self::QrCodeScanV1,
            SdkVerificationMethod::QrCodeShowV1 => Self::QrCodeShowV1,
            SdkVerificationMethod::ReciprocateV1 => Self::ReciprocateV1,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum ServerNoticeType {
    /// The server has exceeded some limit which requires the server administrator to intervene.
    UsageLimitReached,

    Unknown,
}

impl From<SdkServerNoticeType> for ServerNoticeType {
    fn from(value: SdkServerNoticeType) -> Self {
        match value {
            SdkServerNoticeType::UsageLimitReached => Self::UsageLimitReached,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum LimitType {
    /// The server's number of active users in the last 30 days has exceeded the maximum.
    ///
    /// New connections are being refused by the server. What defines "active" is left as an
    /// implementation detail, however servers are encouraged to treat syncing users as "active".
    MonthlyActiveUser,

    Unknown,
}

impl From<SdkLimitType> for LimitType {
    fn from(value: SdkLimitType) -> Self {
        match value {
            SdkLimitType::MonthlyActiveUser => Self::MonthlyActiveUser,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum MessageFormat {
    /// HTML.
    Html,

    Unknown,
}

impl From<SdkMessageFormat> for MessageFormat {
    fn from(value: SdkMessageFormat) -> Self {
        match value {
            SdkMessageFormat::Html => Self::Html,
            _ => Self::Unknown,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct EncryptedFile {
    /// The URL to the file.
    pub url: String,

    /// Version of the encrypted attachments protocol.
    ///
    /// Must be `v2`.
    pub v: String,
}

impl From<Box<SdkEncryptedFile>> for EncryptedFile {
    fn from(value: Box<SdkEncryptedFile>) -> Self {
        Self {
            url: value.url.to_string(),
            v: value.v,
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct ThumbnailInfo {
    /// The height of the thumbnail in pixels.
    pub height: Option<u64>,

    /// The width of the thumbnail in pixels.
    pub width: Option<u64>,

    /// The MIME type of the thumbnail, e.g. "image/png."
    pub mimetype: Option<String>,

    /// The file size of the thumbnail in bytes.
    pub size: Option<u64>,
}

impl From<Box<SdkThumbnailInfo>> for ThumbnailInfo {
    fn from(value: Box<SdkThumbnailInfo>) -> Self {
        Self {
            height: value.height.map(Into::into),
            width: value.width.map(Into::into),
            mimetype: value.mimetype,
            size: value.size.map(Into::into),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub struct StickerEventContent {
    /// A textual representation or associated description of the sticker image.
    ///
    /// This could be the alt text of the original image, or a message to accompany and further
    /// describe the sticker.
    pub body: String,

    /// Metadata about the image referred to in `url` including a thumbnail representation.
    pub info: ImageInfo,

    /// The media source of the sticker image.
    pub source: StickerMediaSource,
}

impl From<SdkStickerEventContent> for StickerEventContent {
    fn from(value: SdkStickerEventContent) -> Self {
        Self {
            body: value.body,
            info: Box::new(value.info).into(),
            source: value.source.into(),
        }
    }
}

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum StickerMediaSource {
    /// The MXC URI to the unencrypted media file.
    Plain(String),

    /// The encryption info of the encrypted media file.
    Encrypted(EncryptedFile),

    Unknown,
}

impl From<SdkStickerMediaSource> for StickerMediaSource {
    fn from(value: SdkStickerMediaSource) -> Self {
        match value {
            SdkStickerMediaSource::Plain(source) => Self::Plain(source.to_string()),
            SdkStickerMediaSource::Encrypted(encrypted) => Self::Encrypted(encrypted.into()),
            _ => Self::Unknown,
        }
    }
}
