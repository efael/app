import "dart:async";

import "package:flutter/cupertino.dart";
import "package:get/get.dart";
import "package:logger/logger.dart";
import "package:messenger/routes.dart";
import "package:messenger/services/chat_service.dart";

import "../../base_controller.dart";

class ChatController extends BaseController with ScrollMixin {
  final chatService = Get.find<ChatService>();

  final showScrollToBottom = false.obs;

  final TextEditingController textController = TextEditingController();

  @override
  void onClose() {
    super.onClose();

    chatService.activeChat.value = null;
  }

  void onPopupMenu(String action) {
    Logger().w(action);
  }

  void openDetails() {
    Get.toNamed(AppRoutes.chatDetails);
  }

  @override
  void onInit() {
    super.onInit();
    // print("herer");
    // scroll.addListener(() {
    //   print(scroll);
    //   print(scroll.position.);
    //   print(scroll.positions);
    //   print(scroll.offset);
    // });

    chatService.activeChatItems.listen((_) {
      Timer(Duration(milliseconds: 50), () {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      });
    });
  }

  @override
  Future<void> onEndScroll() async {}

  @override
  Future<void> onTopScroll() async {}
}
