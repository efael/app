import 'dart:async';

import 'package:get/get.dart';
import 'package:messenger/models/call_history.dart';
import 'package:messenger/models/chat_contact.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:rinf/rinf.dart';

class ChatService extends GetxService {
  late StreamSubscription<RustSignalPack<MatrixRoomDiffResponse>>
  roomDiffListener;
  late StreamSubscription<RustSignalPack<MatrixFetchRoomResponse>>
  fetchRoomListener;
  late StreamSubscription<RustSignalPack<MatrixTimelineItemDiffResponse>>
  timelineItemDiffListener;
  var currentUserId = "".obs;
  var rooms = <Room>[].obs;
  var activeChatItems = <TimelineItem>[].obs;
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
      for (final diff in message.message.value) {
        consumeRoomDiff(diff);
      }
    });
    timelineItemDiffListener = MatrixTimelineItemDiffResponse.rustSignalStream
        .listen((message) {
          if (message.message.field0 != activeChat.value?.id) {
            return;
          }
          for (final diff in message.message.field1) {
            consumeTimelineItemDiff(diff);
          }
        });
    fetchRoomListener = MatrixFetchRoomResponse.rustSignalStream.listen((
      message,
    ) {
      switch (message.message) {
        case MatrixFetchRoomResponseOk(diff: final diff):
          consumeTimelineItemDiff(diff);
      }
    });
  }

  @override
  void onClose() {
    roomDiffListener.cancel();
    fetchRoomListener.cancel();
    super.onClose();
  }

  void init() {
    // MatrixListChatsRequest().sendSignalToRust();
  }

  void consumeRoomDiff(VectorDiffRoom diff) {
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

  void consumeTimelineItemDiff(VectorDiffTimelineItem diff) {
    print("-------");
    print(diff);
    for (var i = 0; i < activeChatItems.length; i++) {
      print("${i} - - - ${activeChatItems[i]}");
    }
    print("-------");

    switch (diff) {
      case VectorDiffTimelineItemAppend(values: final values):
        activeChatItems.addAll(values);
      case VectorDiffTimelineItemClear():
        activeChatItems.clear();
      case VectorDiffTimelineItemPushFront(value: final value):
        activeChatItems.insert(0, value);
      case VectorDiffTimelineItemPushBack(value: final value):
        activeChatItems.add(value);
      case VectorDiffTimelineItemPopFront():
        activeChatItems.removeAt(0);
      case VectorDiffTimelineItemPopBack():
        activeChatItems.removeLast();
      case VectorDiffTimelineItemInsert(index: final index, value: final value):
        activeChatItems.insert(index.toInt(), value);
      case VectorDiffTimelineItemSet(index: final _index, value: final value):
        final index = _index.toInt();

        if (index > activeChatItems.length - 1) {
          print("invalid index set");
          print("old ${index}, ${activeChatItems.length - 1}");
          return;
        }

        final oldElement = activeChatItems.elementAt(index);

        if (value.internalId != oldElement.internalId) {
          print("wrong id set");
          print("old ${oldElement}");
          print("--");
          print("new ${value}");
          return;
        }

        activeChatItems.setAll(index, [value]);
      case VectorDiffTimelineItemRemove(index: final index):
        activeChatItems.removeAt(index.toInt());
      case VectorDiffTimelineItemTruncate(length: final length):
        activeChatItems.removeRange(length.toInt(), rooms.length);
      case VectorDiffTimelineItemReset(values: final values):
        activeChatItems.clear();
        activeChatItems.addAll(values);
    }
  }

  void sendMessage(MatrixSendMessageContent content) {
    if (activeChat.value == null) {
      return;
    }
    MatrixSendMessageRequest(
      roomId: activeChat.value!.id,
      content: content,
    ).sendSignalToRust();
  }

  void loadChat(Room room) {
    activeChat.value = room;
    activeChatItems.clear();
    MatrixFetchRoomRequest(roomId: room.id).sendSignalToRust();
  }

  void clear() {
    activeChat.value = null;

    chatContacts.clear();
    userContacts.clear();
    callHistory.clear();
    unreadMessages.clear();
  }
}
