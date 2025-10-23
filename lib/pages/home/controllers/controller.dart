import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:messenger/AppRoutes.dart';
import 'package:messenger/models/ChatContact.dart';
import 'package:messenger/pages/home/views/_calls.dart';
import 'package:messenger/pages/home/views/_chats.dart';
import 'package:messenger/pages/home/views/_contacts.dart';
import 'package:messenger/pages/home/views/_settings.dart';
import 'package:messenger/repositories/ChatRepo.dart';
import 'package:messenger/services/ChatService.dart';
import 'package:messenger/services/StorageService.dart';

import '../../BaseController.dart';

class HomeController extends BaseController {
  var activeTabKey = "chats".obs;
  var pageTabs = <StackPages>[
    StackPages(key: "contacts", iconPath: "assets/icons/users.svg", page: const ContactsListView()),
    StackPages(
      key: "calls",
      iconPath: "assets/icons/phone.svg",
      page: const CallsListView(),
      disabled: true,
    ),
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

  final chatRepo = ChatRepo();
  final chatService = Get.find<ChatService>();
  final storageService = Get.find<StorageService>();

  final pageScrollController = <String, ScrollController>{
    "contacts": ScrollController(),
    "calls": ScrollController(),
    "chats": ScrollController(),
    "settings": ScrollController(),
  };
  TabController? chatTabsController;

  @override
  void onReady() {
    super.onReady();

    loadChatContacts();
    loadUserContacts();
    loadUserCallsHistory();

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

    storageService.enableCalls.listen((state) {
      var index = findTabIndexByActiveTabKey("calls");
      pageTabs[index].disabled = !state;

      pageTabs.refresh();
    });
  }

  int findTabIndexByActiveTabKey(String key) {
    return pageTabs.indexWhere((it) => it.key == key);
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

  Future loadUserCallsHistory() async {
    try {
      isLoading.value = true;
      chatService.callHistory.value = await chatRepo.loadCallsHistory();
    } catch (e) {
      Logger().e(e);
    } finally {
      isLoading.value = false;
    }
  }

  void openChat(ChatContact model) {
    chatService.activeChat.value = model;

    Get.toNamed(AppRoutes.CHAT);

    // TODO remove
    if (chatService.unreadMessages.containsKey(model.id)) {
      chatService.unreadMessages.remove(model.id);
    }
  }

  void scrollToTop(String key) {
    if (pageScrollController.containsKey(key) && activeTabKey.value == key) {
      if (key == "chats" && pageScrollController[key]?.position.pixels == 0) {
        chatTabsController?.animateTo(
          0,
        );
      } else {
        pageScrollController[key]?.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void logout() {
    storageService.clear();
    chatService.clear();
  }
}

class StackPages {
  final String key;
  final Widget page;
  final String iconPath;
  bool disabled;
  int notificationsCount;

  StackPages({
    required this.key,
    required this.page,
    required this.iconPath,
    this.disabled = false,
    this.notificationsCount = 0,
  });
}

class ChatTabs {
  final String key;
  final String label;
  List<ChatContact> chats;

  ChatTabs({required this.key, required this.label, required this.chats});
}
