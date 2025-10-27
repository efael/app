import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/models/message_types.dart';
import 'package:messenger/widgets/chat_message_bar.dart';
import 'package:messenger/widgets/message_bubble.dart';
import 'package:messenger/widgets/popup_menu_item.dart';
import 'package:messenger/widgets/user_avatar.dart';

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
                  child: UserAvatar(
                    size: 48,
                    userInitials: model?.initials,
                    imagePath: model?.photo,
                  ),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
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
                child: CustomPopupMenuItem(
                  icon: "assets/icons/search.svg",
                  label: "Search",
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: CustomPopupMenuItem(
                  icon: "assets/icons/clear.svg",
                  label: "Clear history",
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: CustomPopupMenuItem(
                  icon: "assets/icons/trash.svg",
                  label: "Delete chat",
                ),
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
                        child: Text(
                          item.message,
                          style: TextStyle(color: Colors.white),
                        ),
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
