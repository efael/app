import 'package:flutter/material.dart';
import 'package:messenger/pages/home/widgets/chat_tile.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../common.dart';

@widgetbook.UseCase(name: 'Default', type: ChatTile, path: "$path/widgets")
Widget buildUseCase(BuildContext context) {
  var room = Room(
    id: "1",
    name: context.knobs.string(label: "Name", initialValue: "Asilbek"),
    lastTs: Uint128.fromBigInt(
      BigInt.from(DateTime.now().toUtc().millisecondsSinceEpoch),
    ),
    isVisited: context.knobs.boolean(label: "Is Visited", initialValue: false),
    avatar: RoomPreviewAvatarText(value: "T"),
    isFavourite: context.knobs.boolean(
      label: "Is Favourite",
      initialValue: false,
    ),
    isEncrypted: context.knobs.boolean(
      label: "Is Encrypted",
      initialValue: false,
    ),
    unreadNotificationCounts: UnreadNotificationsCount(
      highlightCount: Uint64.fromBigInt(BigInt.from(0)),
      notificationCount: Uint64.fromBigInt(BigInt.from(0)),
    ),
  );

  final photoChoice = context.knobs.object.dropdown(
    label: "Photo (choice)",
    options: [
      {"label": "Empty", "url": null},
      {
        "label": "Qora opa",
        "url":
            "https://images.unsplash.com/photo-1761405378292-30f64ad6f60b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1965",
      },
      {
        "label": "Valsaptlik bola",
        "url":
            "https://images.unsplash.com/photo-1761169331195-e079523673c5?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687",
      },
      {
        "label": "G'alati opa",
        "url":
            "https://images.unsplash.com/photo-1760981764631-f375b4231d27?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=687",
      },
    ],
    labelBuilder: (i) => i["label"]!,
  );

  final photoCustomUrl = context.knobs.stringOrNull(label: "Custom photo url");

  // contact.photo = photoChoice["url"] ?? photoCustomUrl;

  return ChatTile(
    room: room,
    onSelectChat: (contact) {},
    unreadMessages: context.knobs.int.slider(
      label: "Unread messages",
      initialValue: 0,
      min: 0,
      max: 100,
    ),
  );
}
