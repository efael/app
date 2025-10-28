import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:messenger/models/chat_contact.dart';
import 'package:messenger/pages/home/views/_calls.dart';
import 'package:messenger/pages/home/views/_chats.dart';
import 'package:messenger/pages/home/views/_contacts.dart';
import 'package:messenger/pages/home/views/_settings.dart';
import 'package:messenger/repositories/chat_repo.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/services/chat_service.dart';
import 'package:messenger/services/storage_service.dart';

import '../../base_controller.dart';
import '../models/stack_page.dart';

class HomeController extends BaseController {
  var activeTabKey = "chats".obs;
  var pageTabs = <StackPage>[
    StackPage(
      key: "contacts",
      iconPath: "assets/icons/users.svg",
      page: const ContactsListView(),
    ),
    StackPage(
      key: "calls",
      iconPath: "assets/icons/phone.svg",
      page: const CallsListView(),
      disabled: true,
    ),
    StackPage(
      key: "chats",
      iconPath: "assets/icons/message.svg",
      page: const ChatListView(),
    ),
    StackPage(
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

    chatService.init();

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

  void openChat(Room room) {
    chatService.activeChat.value = room;

    Get.toNamed(AppRoutes.chat);
  }

  // var i = 1;
  void scrollToTop(String key) {
    // chatService.unreadMessages[1] = i;
    // i++;
    // chatTabs.add(ChatTabs(key: "qwe", label: "Hello", chats: []));
    // chatService.chatContacts.insert(0, chatService.chatContacts.first);

    if (pageScrollController.containsKey(key) && activeTabKey.value == key) {
      if (key == "chats" && pageScrollController[key]?.position.pixels == 0) {
        chatTabsController?.animateTo(0);
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

class ChatTabs {
  final String key;
  final String label;
  List<ChatContact> chats;

  ChatTabs({required this.key, required this.label, required this.chats});
}
