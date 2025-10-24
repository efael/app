import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:messenger/models/chat_contact.dart';
import 'package:messenger/widgets/chat_contact_tile.dart';

class ChatsList extends StatelessWidget {
  final List<ChatContact> models;
  final ValueChanged<ChatContact> onSelectChat;
  final ChatContact? activeChatModel;
  final Map<int, int> unreadMessages;

  const ChatsList({
    super.key,
    required this.models,
    required this.onSelectChat,
    this.activeChatModel,
    required this.unreadMessages,
  });

  @override
  Widget build(BuildContext context) {
    return (models.isNotEmpty)
        ? ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: models.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                color: Color(0x55314356),
                height: 1,
                thickness: 1,
              );
            },
            itemBuilder: (context, i) {
              var item = models[i];

              return ChatContactTile(
                model: item,
                onSelectChat: onSelectChat,
                isActiveChat: item == activeChatModel,
                unreadMessages: (unreadMessages.containsKey(item.id))
                    ? unreadMessages[item.id]!
                    : 0,
              );
            },
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/folder.svg",
                  width: 128,
                  height: 128,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                Text("empty".tr, style: TextStyle(fontSize: 24)),
              ],
            ),
          );
  }
}
