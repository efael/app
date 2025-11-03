import "package:flutter/material.dart";
import "package:messenger/helpers_wb.dart";
import "package:messenger/pages/home/widgets/bottom_navigation_bar.dart";
import "package:messenger/pages/home/widgets/chat_list.dart";
import "package:messenger/pages/home/widgets/chat_list_header.dart";
import "package:messenger/pages/home/widgets/chat_tile.dart";
import "package:messenger/rinf/bindings/bindings.dart";
import "package:widgetbook/widgetbook.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "../common_wb.dart";

class Chats extends EmptyWidget {
  const Chats({super.key});
}

@widgetbook.UseCase(name: "Default", type: Chats, path: "$path/views")
Widget buildUseCase(BuildContext context) {
  final title = context.knobs.string(label: "Title", initialValue: "Efael");
  final contacts = context.knobs.int.slider(
    label: "Contacts",
    initialValue: 0,
    min: 0,
    max: 50,
  );
  final models = List.generate(
    contacts,
    (i) => Room(
      id: i.toString(),
      name: "Contact $i",
      lastTs: Uint128.fromBigInt(
        BigInt.from(DateTime.now().toUtc().millisecondsSinceEpoch),
      ),
      isVisited: true,
      avatar: RoomPreviewAvatarText(value: "T"),
      isFavourite: false,
      isEncrypted: false,
      unreadNotificationCounts: UnreadNotificationsCount(
        highlightCount: Uint64.fromBigInt(BigInt.from(0)),
        notificationCount: Uint64.fromBigInt(BigInt.from(0)),
      ),
    ),
    growable: true,
  );

  return Scaffold(
    body: IndexedStack(
      index: 2,
      children: pageTabs(
        chats: Scaffold(
          body: DefaultTabController(
            length: 1,
            child: NestedScrollView(
              controller: ScrollController(),
              headerSliverBuilder: (_, __) => [ChatListHeader(title: title)],
              body: TabBarView(
                children: [
                  ChatList(
                    itemCount: contacts,
                    itemBuilder: (context, index) {
                      final item = models[index];
                      return ChatTile(room: item, onSelectChat: (contact) {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ).map((item) => item.page).toList(),
    ),
    bottomNavigationBar: HomeBottomNavigationBar(
      items: bottomTabs,
      activeItemKey: "chats",
      onTap: (key) {},
    ),
  );
}
