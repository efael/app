import 'package:flutter/material.dart';
import 'package:messenger/widgets/chat_item.dart';
import 'package:messenger/src/bindings/bindings.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/helpers/mock_room_info.dart';

@widgetbook.UseCase(name: 'Default', type: ChatItem)
Widget build(BuildContext context) {
  final RoomInfo roomInfo = mockRoomInfo(displayName: "Awesome chat");

  return ChatItem(roomInfo: roomInfo);
}
