import "package:flutter/widgets.dart";
import "package:intl/intl.dart";
import "package:messenger/rinf/bindings/bindings.dart";
import "package:messenger/widgets/message_bubble.dart";

class TimelineItemRender extends StatelessWidget {
  const TimelineItemRender({
    super.key,
    required this.item,
    required this.currentUserId,
  });

  final TimelineItem item;
  final String currentUserId;

  Widget? get render {
    switch (item.kind) {
      case TimelineItemKindEvent(value: final event):
        late Profile profile;
        switch (event.senderProfile) {
          case TimelineDetailsProfileReady(value: final value):
            profile = value;
          case TimelineDetailsProfilePending():
            profile = Profile(displayNameAmbiguous: true);
          case TimelineDetailsProfileError(value: final error):
            print(error);
            profile = Profile(displayNameAmbiguous: true);
          case TimelineDetailsProfileUnavailable():
            profile = Profile(displayNameAmbiguous: true);
        }

        final sentByCurrentUser = currentUserId == event.sender;

        final sentAt = DateFormat(
          "HH:mm",
        ).format(DateTime.fromMillisecondsSinceEpoch(event.timestamp.toInt()));

        switch (event.content) {
          case TimelineItemContentMsgLike(value: final msgLike):
            switch (msgLike.kind) {
              case MsgLikeKindMessage(value: final message):
                switch (message.msgtype) {
                  case MessageTypeText(value: final text):
                    return MessageBubble(
                      profile: profile,
                      sentAt: sentAt,
                      sentByCurrentUser: sentByCurrentUser,
                      child: Text(text.body),
                    );
                }
            }
        }
      case TimelineItemKindVirtual(value: final virtual):
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return render ?? SizedBox.shrink();
  }
}
