import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/models/message_types.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:messenger/widgets/chat_message_bar.dart';
import 'package:messenger/widgets/message_bubble.dart';
import 'package:messenger/widgets/popup_menu_item.dart';
import 'package:messenger/widgets/timeline_item_render.dart';
import 'package:messenger/widgets/user_avatar.dart';

import '../controllers/controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final room = controller.chatService.activeChat.value;

    return Scaffold(
      backgroundColor: consts.colors.dominant.bgHighContrast.dark,
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
                    avatar: room?.avatar ?? RoomPreviewAvatarText(value: " "),
                    size: 48,
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
                          room?.name ?? "",
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
                          // room?.lastSeen ?? "",
                          "",
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
                  itemCount: controller.chatService.activeChatItems.length,
                  itemBuilder: (c, i) {
                    final item = controller.chatService.activeChatItems[i];
                    print(item);

                    return TimelineItemRender(
                      item: item,
                      currentUserId: controller.chatService.currentUserId.value,
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
