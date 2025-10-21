import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:messenger/models/ChatContact.dart';
import 'package:messenger/widgets/ChatContactTile.dart';
import 'package:get/get.dart';

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
        ? ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: models.length,
            itemBuilder: (context, i) {
              var item = models[i];

              return ChatContactTile(
                model: item,
                onSelectChat: onSelectChat,
                isActiveChat: item == activeChatModel,
                unreadMessages: (unreadMessages.containsKey(item.id)) ? unreadMessages[item.id]! : 0,
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
