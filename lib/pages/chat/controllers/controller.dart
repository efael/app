import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:messenger/enums/message_state.dart';
import 'package:messenger/enums/message_type.dart';
import 'package:messenger/models/message_types.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/services/chat_service.dart';

import '../../base_controller.dart';

class ChatController extends BaseController {
  final chatService = Get.find<ChatService>();

  final messages = <BaseMessageType>[
    TextMessageTypes(
      id: 12,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 05),
      sender: 777,
      message: "Good luck on your quest. May your brew be strong.",
    ),
    TextMessageTypes(
      id: 11,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 03),
      sender: 3,
      message:
          "True dedication. Anyway, gotta go find coffee. Need energy for the rest of this 'week'.",
    ),
    TextMessageTypes(
      id: 10,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 05),
      sender: 777,
      message: "Yeah! He was really committed to that single crumb. Respect.",
    ),
    TextMessageTypes(
      id: 9,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 03),
      sender: 3,
      message: "Which one? The chunky gray one?",
    ),
    TextMessageTypes(
      id: 8,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 05),
      sender: 777,
      message: "Yeah lol. Did you see that bird outside the window?",
    ),
    TextMessageTypes(
      id: 7,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 03),
      sender: 3,
      message: "...No way.",
    ),
    TextMessageTypes(
      id: 6,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 05),
      sender: 777,
      message: "Wait, it’s Thursday.",
    ),
    TextMessageTypes(
      id: 5,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 03),
      sender: 3,
      message: "Totally. And it’s only Wednesday.",
    ),
    TextMessageTypes(
      id: 4,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 05),
      sender: 777,
      message: "Oh man, it's a grind. Feels like Tuesday still.",
    ),
    TextMessageTypes(
      id: 3,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 03),
      sender: 3,
      message: "Is it just me or is this week going by really slow?",
    ),
    TextMessageTypes(
      id: 2,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 05),
      sender: 777,
      message: "Sup?",
    ),
    TextMessageTypes(
      id: 1,
      type: MessageType.text,
      status: MessageState.read,
      time: DateTime(2025, 10, 24, 04, 03),
      sender: 3,
      message: "Hey",
    ),
  ].obs;
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
    messages.insert(
      0,
      TextMessageTypes(
        id: 9,
        type: MessageType.text,
        status: MessageState.read,
        time: DateTime.now(),
        sender: 777,
        message: msg,
      ),
    );
  }
}
