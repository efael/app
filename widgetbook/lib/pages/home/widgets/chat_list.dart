import 'package:flutter/material.dart';
import 'package:messenger/models/chat_contact.dart';
import 'package:messenger/pages/home/widgets/chat_list.dart';
import 'package:messenger/pages/home/widgets/chat_tile.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../common.dart';

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
    (i) => ChatContact(
      id: i,
      firstName: "Contact $i",
      lastName: "",
      lastMessage: "",
      time: DateTime.now(),
    ),
    growable: true,
  );

  return ChatList(
    itemCount: contacts,
    itemBuilder: (BuildContext context, int index) {
      final item = models[index];
      return ChatTile(model: item, onSelectChat: (contact) {});
    },
  );
}
