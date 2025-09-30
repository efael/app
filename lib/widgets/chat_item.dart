import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/src/bindings/signals/signals.dart';
import 'package:messenger/utils.dart';
import 'package:messenger/widgets/message_preview.dart';
import 'package:messenger/widgets/username.dart';
import 'package:messenger/widgets/userpic.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.roomInfo,
    this.latestEvent,

    this.onTap,
    this.onLongPress,
  });

  final RoomInfo roomInfo;
  final EventTimelineItem? latestEvent;

  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    // print(roomInfo.displayName);
    // print(roomInfo);
    // print(latestEvent);
    // print("====\n====\n====");
    return Container(
      color: consts.colors.dominant.bgHighContrast,
      height: 80,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: consts.colors.dominant.bgMediumContrast,
          highlightColor: consts.colors.dominant.bgLowContrast,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              spacing: 12,
              children: [
                Userpic(name: roomInfo.displayName ?? " "),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Username(name: roomInfo.displayName ?? "-"),
                          if (latestEvent != null)
                            Text(
                              formatTimestamp(latestEvent!.timestamp),
                              style: consts.typography.text3,
                            ),
                        ],
                      ),
                      MessagePreview(event: latestEvent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
