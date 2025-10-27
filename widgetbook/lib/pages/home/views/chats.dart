import 'package:flutter/material.dart';
import 'package:messenger/models/chat_contact.dart';
import 'package:messenger/pages/home/widgets/bottom_navigation_bar.dart';
import 'package:messenger/pages/home/widgets/chat_list.dart';
import 'package:messenger/pages/home/widgets/chat_list_header.dart';
import 'package:messenger/pages/home/widgets/chat_tile.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/helpers.dart';

import '../common.dart';

class Chats extends EmptyWidget {
  const Chats({super.key});
}

@widgetbook.UseCase(name: 'Default', type: Chats, path: "$path/views")
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
    (i) => ChatContact(
      id: i,
      firstName: "Contact $i",
      lastName: "",
      lastMessage: "",
      time: DateTime.now(),
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
                      return ChatTile(model: item, onSelectChat: (contact) {});
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
