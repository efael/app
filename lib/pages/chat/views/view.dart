import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/models/MessageTypes.dart';
import 'package:messenger/widgets/ChatMessageBar.dart';
import 'package:messenger/widgets/CustomPopupMenuItem.dart';
import 'package:messenger/widgets/MessageBubble.dart';
import 'package:messenger/widgets/UserAvatar.dart';

import '../controllers/controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = controller.chatService.activeChat.value;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: GestureDetector(
          onTap: controller.openDetails,
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Hero(
                  tag: "userImage",
                  child: UserAvatar(size: 48, userInitials: model?.initials, imagePath: model?.photo),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: "userName",
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          model?.fullName,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Hero(
                      tag: "userStatus",
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          model?.lastSeen ?? "",
                          style: TextStyle(fontSize: 12),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (c) => [
              const PopupMenuItem(
                value: 'search',
                child: CustomPopupMenuItem(icon: "assets/icons/search.svg", label: "Search"),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: CustomPopupMenuItem(icon: "assets/icons/clear.svg", label: "Clear history"),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: CustomPopupMenuItem(icon: "assets/icons/trash.svg", label: "Delete chat"),
              ),
            ],
            onSelected: controller.onPopupMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (c, i) {
                    final item = controller.messages[i] as TextMessageTypes;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1),
                      child: MessageBubble(
                        model: item,
                        child: Text(item.message, style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),
            ),
            ChatMessageBar(onSendMessage: controller.onNewMessage),
          ],
        ),
      ),
    );
  }
}
