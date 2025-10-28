import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:messenger/widgets/svg_image.dart';
import 'package:messenger/widgets/time_ago_text.dart';
import 'package:messenger/widgets/user_avatar.dart';

class ChatTile extends StatelessWidget {
  final Room room;
  final ValueChanged<Room> onSelectChat;
  final bool isActiveChat;
  final int unreadMessages;

  const ChatTile({
    super.key,
    required this.room,
    required this.onSelectChat,
    this.unreadMessages = 0,
    this.isActiveChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: ListTile(
        tileColor: (isActiveChat) ? Color(0xFF2B415A) : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => onSelectChat(room),
        title: (room.isEncrypted)
            ? Row(
                children: [
                  SvgImage(
                    "assets/icons/lock.svg",
                    color: consts.colors.accent.green.dark,
                  ),
                  SizedBox(width: 3),
                  Text(
                    room.name,
                    style: consts.typography.text1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: consts.colors.accent.green.dark,
                    ),
                  ),
                ],
              )
            : Text(
                room.name,
                style: consts.typography.text1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: consts.colors.accent.white.dark,
                ),
              ),
        subtitle: Text(
          room.lastMessage ?? "",
          maxLines: 2,
          style: consts.typography.text2,
        ),
        leading: Stack(
          children: [
            UserAvatar(avatar: room.avatar),
            // TODO
            // if (room.isOnline)
            if (false)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: consts.colors.accent.green.dark,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: consts.colors.dominant.bgMediumContrast.dark,
                      width: 3,
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            room.lastTs == null
                ? SizedBox.shrink()
                : TimeAgoText(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(
                      room.lastTs!.toBigInt().toInt(),
                    ),
                    style: consts.typography.text3,
                  ),
            (unreadMessages > 0)
                ? Container(
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                      maxWidth: 24,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: consts.colors.accent.bluePrimary.dark,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Text(
                        (unreadMessages > 99)
                            ? "99+"
                            : unreadMessages.toString(),
                        style: TextStyle(
                          color: consts.colors.accent.white.dark,
                          fontSize: unreadMessages < 10 ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
