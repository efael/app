use matrix_sdk::{
    Room as SdkRoom,
    deserialized_responses::{TimelineEvent, TimelineEventKind},
};
use ruma::{
    events::{
        room::message::RoomMessageEventContent, AnyMessageLikeEvent, AnyTimelineEvent, MessageLikeEvent
    }, OwnedRoomId, RoomId
};

pub fn deserialize_event(
    event: &TimelineEvent,
    room_id: String,
) -> Result<AnyTimelineEvent, serde_json::Error> {
    let room_id = <&RoomId>::try_from(room_id.as_str()).unwrap();
    let room_id = OwnedRoomId::from(room_id);

    match &event.kind {
        TimelineEventKind::Decrypted(decrypted) => Ok(decrypted.event.deserialize()?.into()),
        TimelineEventKind::PlainText { event } => Ok(event.deserialize()?.into_full_event(room_id)),
        TimelineEventKind::UnableToDecrypt { event, .. } => {
            Ok(event.deserialize()?.into_full_event(room_id))
        }
    }
}

pub fn get_room_message_event(
    room: &SdkRoom,
    event: &TimelineEvent,
) -> Option<MessageLikeEvent<RoomMessageEventContent>> {
    let event = match deserialize_event(event, room.room_id().to_string()) {
        Ok(event) => event,
        Err(_) => { return None; }
    };

    let event = match event {
        AnyTimelineEvent::MessageLike(AnyMessageLikeEvent::RoomMessage(event)) => event,
        _ => { return None; }
    };

    Some(event)
}