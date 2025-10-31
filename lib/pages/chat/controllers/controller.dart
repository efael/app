import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/services/chat_service.dart';

import '../../base_controller.dart';

class ChatController extends BaseController {
  final chatService = Get.find<ChatService>();

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

  void onNewMessage(String msg) {
    // messages.insert(
    //   0,
    //   TextMessageTypes(
    //     id: 9,
    //     type: MessageType.text,
    //     status: MessageState.read,
    //     time: DateTime.now(),
    //     sender: 777,
    //     message: msg,
    //   ),
    // );
  }
}
