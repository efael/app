import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:messenger/pages/home/controllers/controller.dart";
import "package:messenger/pages/home/widgets/chat_list.dart";
import "package:messenger/pages/home/widgets/chat_tile.dart";

class ChatListView extends GetView<HomeController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => DefaultTabController(
        length: controller.chatTabs.length + 1,
        child: Builder(
          builder: (context) {
            controller.chatTabsController = DefaultTabController.of(context);

            return Scaffold(
              body: NestedScrollView(
                controller: controller.pageScrollController["chats"],
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                      return [
                        Obx(
                          () => SliverAppBar(
                            pinned: true,
                            floating: true,
                            title: Text("Efael"),
                            actions: [
                              IconButton(
                                onPressed: () => {},
                                icon: Icon(Icons.search),
                              ),
                            ],
                            bottom: (controller.chatTabs.isNotEmpty)
                                ? TabBar(
                                    isScrollable: true,
                                    padding: EdgeInsets.zero,
                                    tabAlignment: TabAlignment.start,
                                    dividerColor: Color(0xFF314356),
                                    labelStyle: TextStyle(fontSize: 14),
                                    tabs: [
                                      Tab(text: "all".tr),
                                      ...controller.chatTabs.map(
                                        (it) => Tab(text: it.label),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      ];
                    },
                body: Obx(
                  () => TabBarView(
                    children: [
                      ChatList(
                        itemCount: controller.chatService.rooms.length,
                        itemBuilder: (context, index) {
                          final room = controller.chatService.rooms[index];

                          return ChatTile(
                            room: room,
                            onSelectChat: controller.openChat,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
