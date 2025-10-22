import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messenger/models/ChatContact.dart';
import 'package:messenger/widgets/TimeAgoText.dart';
import 'package:messenger/widgets/UserAvatar.dart';

class ChatContactTile extends StatelessWidget {
  final ChatContact model;
  final ValueChanged<ChatContact> onSelectChat;
  final bool isActiveChat;
  final int unreadMessages;

  const ChatContactTile({
    super.key,
    required this.model,
    required this.onSelectChat,
    this.unreadMessages = 0,
    this.isActiveChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        tileColor: (isActiveChat) ? Color(0xFF2B415A) : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => onSelectChat(model),
        title: (model.isSecretChat)
            ? Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/lock.svg",
                    colorFilter: ColorFilter.mode(Color(0xFF35C47C), BlendMode.srcIn),
                  ),
                  SizedBox(width: 3),
                  Text(
                    model.fullName,
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF35C47C)),
                  ),
                ],
              )
            : Text(model.fullName, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(model.lastMessage, maxLines: 2, style: TextStyle(color: Color(0xFF6C808C))),
        leading: Stack(
          children: [
            UserAvatar(imagePath: model.photo, userInitials: model.initials),
            if (model.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Color(0xFF35C47C),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                  ),
                ),
              ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TimeAgoText(dateTime: model.time),
            (unreadMessages > 0)
                ? Container(
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24, maxWidth: 24),
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Text(
                        unreadMessages.toString(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
