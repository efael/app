import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/src/bindings/signals/signals.dart';

class MessagePreview extends StatelessWidget {
  const MessagePreview({super.key, this.event});

  final EventTimelineItem? event;

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return SizedBox(height: 32);
    }

    // ignore: no_leading_underscores_for_local_identifiers
    final _event = event!;

    switch (_event.content) {
      case TimelineItemContentMsgLike(content: final content):
        switch (content.kind) {
          case MsgLikeKindMessage(content: final content):
            switch (content.msgType) {
              case MessageTypeText(content: final content):
                return SizedBox(
                  height: 32,
                  child: Text(content.body, style: consts.typography.text2),
                );
              case MessageTypeNotice(content: final content):
                return SizedBox(
                  height: 32,
                  child: Text(content.body, style: consts.typography.text2),
                );
            }
          // return Text(content.);
        }
    }

    return SizedBox(height: 32);
  }
}
