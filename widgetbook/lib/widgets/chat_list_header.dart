import 'package:flutter/material.dart';
import 'package:messenger/widgets/chat_list_header.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/helpers/very_long_text.dart';

@widgetbook.UseCase(name: 'Default', type: ChatListHeader)
Widget build(BuildContext context) {
  return ChatListHeader(
    appName: context.knobs.string(label: "App name", initialValue: "Efael"),
  );
}

@widgetbook.UseCase(name: 'Long Text', type: ChatListHeader)
Widget buildLongText(BuildContext context) {
  return ChatListHeader(
    appName: context.knobs.string(
      label: "App name",
      initialValue: veryLongText,
    ),
  );
}
