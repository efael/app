import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/pages/home/controllers/controller.dart';
import 'package:messenger/widgets/ChatsList.dart';

class ChatListView extends GetView<HomeController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.chatTabs.length + 1,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: true,
                title: Text("Efael"),
                actions: [IconButton(onPressed: () => {}, icon: Icon(Icons.search))],
                bottom: (controller.chatTabs.isNotEmpty)
                    ? TabBar(
                        isScrollable: true,
                        padding: EdgeInsets.zero,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Color(0xFF314356),
                        labelStyle: TextStyle(fontSize: 14),
                        tabs: [
                          Tab(text: 'all'.tr),
                          ...controller.chatTabs.map((it) => Tab(text: it.label)),
                        ],
                      )
                    : null,
              ),
            ];
          },
          body: Obx(
            () => TabBarView(
              children: [
                ChatsList(
                  models: controller.chatService.chatContacts,
                  onSelectChat: controller.openChat,
                  activeChatModel: controller.chatService.activeChat.value,
                  unreadMessages: controller.chatService.unreadMessages,
                ),
                ...controller.chatTabs.map(
                  (it) => ChatsList(
                    models: it.chats,
                    onSelectChat: controller.openChat,
                    activeChatModel: controller.chatService.activeChat.value,
                    unreadMessages: controller.chatService.unreadMessages,
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
