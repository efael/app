import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:messenger/models/ChatContact.dart';
import 'package:messenger/pages/home/views/_calls.dart';
import 'package:messenger/pages/home/views/_chats.dart';
import 'package:messenger/pages/home/views/_contacts.dart';
import 'package:messenger/pages/home/views/_settings.dart';
import 'package:messenger/repositories/ChatRepo.dart';
import 'package:messenger/services/ChatService.dart';

import '../../BaseController.dart';

class HomeController extends BaseController {
  var activeTabKey = "chats".obs;
  var pageTabs = <StackPages>[
    StackPages(key: "contacts", iconPath: "assets/icons/users.svg", page: const ContactsListView()),
    StackPages(key: "chats", iconPath: "assets/icons/message.svg", page: const ChatListView()),
    StackPages(
      key: "settings",
      iconPath: "assets/icons/settings.svg",
      page: const SettingsView(),
      notificationsCount: 3,
    ),
  ].obs;

  // TODO remove list elements
  var chatTabs = <ChatTabs>[
    ChatTabs(key: "design", label: "Дизайн", chats: []),
    ChatTabs(key: "business", label: "Бизнес", chats: []),
    ChatTabs(key: "rest", label: "Отдых", chats: []),
  ].obs;

  var chatRepo = ChatRepo();
  var chatService = Get.find<ChatService>();

  @override
  void onReady() {
    super.onReady();

    // To enable calls tab
    // enableOrDisableCalls(true);

    loadChatContacts();
    loadUserContacts();

    watchesAndFixes();

    // TODO remove this
    chatService.unreadMessages.value = {1: 85, 6: 3};
  }

  void watchesAndFixes() {
    chatService.unreadMessages.listen((it) {
      var counts = it.values;
      var index = findTabIndexByActiveTabKey("chats");

      if (counts.length == 1) {
        pageTabs[index].notificationsCount = counts.first;
      } else {
        pageTabs[index].notificationsCount = counts.length;
      }

      pageTabs.refresh();
      chatTabs.refresh();
    });
  }

  int findTabIndexByActiveTabKey(String key) {
    return this.pageTabs.indexWhere((it) => it.key == key);
  }

  Future loadChatContacts() async {
    try {
      isLoading.value = true;
      chatService.chatContacts.value = await chatRepo.loadChatContacts();
    } catch (e) {
      Logger().e(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future loadUserContacts() async {
    try {
      isLoading.value = true;
      chatService.userContacts.value = await chatRepo.loadUserContacts();
    } catch (e) {
      Logger().e(e);
    } finally {
      isLoading.value = false;
    }
  }

  void openChat(ChatContact model) {
    chatService.activeChat.value = model;

    if (chatService.unreadMessages.containsKey(model.id)) {
      chatService.unreadMessages.remove(model.id);
    }
  }

  void enableOrDisableCalls(bool state) {
    var index = 1;
    var key = "calls";

    if (state) {
      if (this.pageTabs[index].key != key) {
        this.pageTabs.insert(
          index,
          StackPages(key: key, iconPath: "assets/icons/phone.svg", page: const CallsListView()),
        );
      }
    } else {
      if (this.pageTabs[index].key == key) {
        this.pageTabs.removeAt(index);
      }
    }
  }
}

class StackPages {
  final String key;
  final Widget page;
  final String iconPath;
  int notificationsCount;

  StackPages({
    required this.key,
    required this.page,
    required this.iconPath,
    this.notificationsCount = 0,
  });
}

class ChatTabs {
  final String key;
  final String label;
  List<ChatContact> chats;

  ChatTabs({required this.key, required this.label, required this.chats});
}
