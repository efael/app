import 'package:flutter/material.dart';
import 'package:messenger/widgets/chat_header.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/helpers/very_long_text.dart';

@widgetbook.UseCase(name: 'Default', type: ChatHeader)
Widget build(BuildContext context) {
  return ChatHeader(
    userName: context.knobs.string(
      label: "User name",
      initialValue: "Test user",
    ),
    onBackTap: () {
      print("Back tapped");
    },
    onSearchTap: () {
      print("Search tapped");
    },
  );
}

@widgetbook.UseCase(name: 'Long Text', type: ChatHeader)
Widget buildLongText(BuildContext context) {
  return ChatHeader(
    userName: context.knobs.string(
      label: "User name",
      initialValue: veryLongText,
    ),
    onBackTap: () {
      print("Back tapped");
    },
    onSearchTap: () {
      print("Search tapped");
    },
  );
}
