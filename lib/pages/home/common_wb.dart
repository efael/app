import "package:flutter/material.dart";
import "package:messenger/pages/home/models/nav_item.dart";
import "package:messenger/pages/home/models/stack_page.dart";

const String path = "pages/home";

var pageTabs =
    ({Widget? contacts, Widget? calls, Widget? chats, Widget? settings}) =>
        <StackPage>[
          StackPage(
            key: "contacts",
            iconPath: "assets/icons/users.svg",
            page: contacts ?? Placeholder(),
          ),
          StackPage(
            key: "calls",
            iconPath: "assets/icons/phone.svg",
            page: calls ?? Placeholder(),
            disabled: true,
          ),
          StackPage(
            key: "chats",
            iconPath: "assets/icons/message.svg",
            page: chats ?? Placeholder(),
          ),
          StackPage(
            key: "settings",
            iconPath: "assets/icons/settings.svg",
            page: settings ?? Placeholder(),
            notificationsCount: 3,
          ),
        ];

var bottomTabs = pageTabs()
    .where((it) => !it.disabled)
    .map(
      (it) => NavItem(
        key: it.key,
        label: it.key,
        iconPath: it.iconPath,
        count: it.notificationsCount,
      ),
    )
    .toList();
