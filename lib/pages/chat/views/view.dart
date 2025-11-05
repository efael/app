import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:messenger/constants.dart";
import "package:messenger/rinf/bindings/bindings.dart";
import "package:messenger/widgets/chat_message_bar.dart";
import "package:messenger/widgets/popup_menu_item.dart";
import "package:messenger/widgets/timeline_item_render.dart";
import "package:messenger/widgets/user_avatar.dart";

import "../controllers/controller.dart";

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ScrollController scrollController;
  bool isLoadingOlder = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
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
                value: "search",
                child: CustomPopupMenuItem(
                  icon: "assets/icons/search.svg",
                  label: "Search",
                ),
              ),
              const PopupMenuItem(
                value: "clear",
                child: CustomPopupMenuItem(
                  icon: "assets/icons/clear.svg",
                  label: "Clear history",
                ),
              ),
              const PopupMenuItem(
                value: "delete",
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Obx(
                    () => RefreshIndicator(
                      onRefresh: () async {
                        // Also allow pull-down refresh for pagination
                        setState(() => isLoadingOlder = true);
                        controller.chatService.paginateBackwards();
                        setState(() => isLoadingOlder = false);
                      },
                      backgroundColor: consts.colors.dominant.bgHighContrast.light,
                      displacement: 20,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        itemCount:
                            controller.chatService.activeChatItems.length + (isLoadingOlder ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show top loader as first element
                          if (isLoadingOlder && index == 0) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }

                          final itemIndex =
                              isLoadingOlder ? index - 1 : index;
                          final item =
                              controller.chatService.activeChatItems[itemIndex];
                          return TimelineItemRender(
                            item: item,
                            currentUserId:
                                controller.chatService.currentUserId.value,
                          );
                        },
                      ),
                    ),
                  ),
                  Obx(
                    () => AnimatedPositioned(
                      bottom: controller.showScrollToBottom.value ? 8 : -60,
                      right: 8,
                      duration: const Duration(milliseconds: 200),
                      child: IconButton.filledTonal(
                        onPressed: () {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        icon: const Icon(Icons.arrow_downward),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ChatMessageBar(onSendMessage: controller.chatService.sendMessage),
          ],
        ),
      ),
    );
  }
}