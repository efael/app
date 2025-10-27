import 'package:flutter/material.dart';
import 'package:messenger/models/chat_contact.dart';
import 'package:messenger/pages/home/widgets/chat_tile.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../common.dart';

@widgetbook.UseCase(name: 'Default', type: ChatTile, path: "$path/widgets")
Widget buildUseCase(BuildContext context) {
  var contact = ChatContact(
    id: 1,
    firstName: context.knobs.string(
      label: "First Name",
      initialValue: "Asilbek",
    ),
    lastName: context.knobs.string(
      label: "Last Name",
      initialValue: "Abdullayev",
    ),
    lastMessage: context.knobs.string(
      label: "Last Message",
      initialValue: "Salom!",
    ),
    time: context.knobs.dateTime(
      label: "Last Message Date",
      initialValue: DateTime.now(),
      start: DateTime.now().subtract(Duration(days: 3650)),
      end: DateTime.now(),
    ),
    isGroup: context.knobs.boolean(label: "Is Group", initialValue: false),
    isOnline: context.knobs.boolean(label: "Is Online", initialValue: false),
    isPinned: context.knobs.boolean(label: "Is Pinned", initialValue: false),
    isSecretChat: context.knobs.boolean(
      label: "Is Secret Chat",
      initialValue: false,
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

  contact.photo = photoChoice["url"] ?? photoCustomUrl;

  return ChatTile(
    model: contact,
    onSelectChat: (contact) {},
    unreadMessages: context.knobs.int.slider(
      label: "Unread messages",
      initialValue: 0,
      min: 0,
      max: 100,
    ),
  );
}
