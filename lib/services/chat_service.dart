import 'dart:async';

import 'package:get/get.dart';
import 'package:messenger/models/call_history.dart';
import 'package:messenger/models/chat_contact.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:rinf/rinf.dart';

class ChatService extends GetxService {
  late StreamSubscription<RustSignalPack<MatrixRoomDiffResponse>>
  roomDiffListener;
  var rooms = <Room>[].obs;
  var chatContacts = <ChatContact>[].obs;
  var activeChat = Rx<Room?>(null);
  var unreadMessages = <int, int>{}.obs;

  var userContacts = <ChatContact>[].obs;
  var callHistory = <CallHistory>[].obs;

  @override
  void onReady() {
    super.onReady();
    roomDiffListener = MatrixRoomDiffResponse.rustSignalStream.listen((
      message,
    ) {
      print("room list upd");
      print(message);
      for (final diff in message.message.value) {
        switch (diff) {
          case VectorDiffRoomAppend(values: final values):
            rooms.addAll(values);
          case VectorDiffRoomClear():
            rooms.clear();
          case VectorDiffRoomPushFront(value: final value):
            rooms.add(value);
          case VectorDiffRoomPushBack(value: final value):
            rooms.insert(0, value);
          case VectorDiffRoomPopFront():
            rooms.removeLast();
          case VectorDiffRoomPopBack():
            rooms.removeAt(0);
          case VectorDiffRoomInsert(index: final index, value: final value):
            rooms.insert(index.toInt(), value);
          case VectorDiffRoomSet(index: final index, value: final value):
            rooms.setAll(index.toInt(), [value]);
          case VectorDiffRoomRemove(index: final index):
            rooms.removeAt(index.toInt());
          case VectorDiffRoomTruncate(length: final length):
            rooms.removeRange(length.toInt(), rooms.length);
          case VectorDiffRoomReset(values: final values):
            rooms.clear();
            rooms.addAll(values);
        }
      }
    });
  }

  @override
  void onClose() {
    roomDiffListener.cancel();
    super.onClose();
  }

  void init() {
    // MatrixListChatsRequest().sendSignalToRust();
  }

  void clear() {
    activeChat.value = null;

    chatContacts.clear();
    userContacts.clear();
    callHistory.clear();
    unreadMessages.clear();
  }
}
