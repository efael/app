import 'package:flutter/material.dart';
import 'package:messenger/pages/home/widgets/chat_list.dart';
import 'package:messenger/pages/home/widgets/chat_tile.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../common_wb.dart';

@widgetbook.UseCase(name: 'Default', type: ChatList, path: "$path/widgets")
Widget buildUseCase(BuildContext context) {
  final contacts = context.knobs.int.slider(
    label: "Contacts",
    initialValue: 0,
    min: 0,
    max: 50,
  );
  final models = List.generate(
    contacts,
    (i) => Room(
      id: i.toString(),
      name: "Contact $i",
      lastTs: Uint128.fromBigInt(
        BigInt.from(DateTime.now().toUtc().millisecondsSinceEpoch),
      ),
      isVisited: true,
      avatar: RoomPreviewAvatarText(value: "T"),
      isFavourite: false,
      isEncrypted: false,
      unreadNotificationCounts: UnreadNotificationsCount(
        highlightCount: Uint64.fromBigInt(BigInt.from(0)),
        notificationCount: Uint64.fromBigInt(BigInt.from(0)),
      ),
    ),
    growable: true,
  );

  return ChatList(
    itemCount: contacts,
    itemBuilder: (BuildContext context, int index) {
      final item = models[index];
      return ChatTile(room: item, onSelectChat: (contact) {});
    },
  );
}
