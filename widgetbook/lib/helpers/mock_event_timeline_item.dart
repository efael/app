import 'package:messenger/src/bindings/bindings.dart';

EventTimelineItem mockEventTimelineItem() => EventTimelineItem(
  isRemote: true,
  eventOrTransactionId: EventOrTransactionIdEventId(eventId: ""),
  sender: "Sender",
  senderProfile: ProfileDetailsReady(
    displayNameAmbiguous: false,
    displayName: "Sender",
  ),
  isOwn: true,
  isEditable: true,
  content: TimelineItemContentMsgLike(
    content: MsgLikeContent(
      kind: MsgLikeKindMessage(
        content: MessageContent(
          msgType: MessageTypeText(content: TextMessageContent(body: "Text")),
          body: "Body",
          isEdited: false,
        ),
      ),
      reactions: [],
    ),
  ),
  timestamp: Timestamp(
    value: Uint64(BigInt.from(DateTime.now().millisecondsSinceEpoch)),
  ),
  readReceipts: {},
  canBeRepliedTo: true,
);
