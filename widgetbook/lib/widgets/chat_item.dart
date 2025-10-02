import 'package:flutter/material.dart';
import 'package:messenger/widgets/chat_item.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/helpers/very_long_text.dart';

DateTime buildDateTime(
  BuildContext context, {
  DateTime? initialValue,
  DateTime? start,
  DateTime? end,
}) => context.knobs.dateTime(
  label: "Date time",
  initialValue: initialValue ?? DateTime.now(),
  start: start ?? DateTime.now().subtract(const Duration(days: 365 * 10)),
  end: end ?? DateTime.now(),
);

@widgetbook.UseCase(name: 'Default', type: ChatItem)
Widget build(BuildContext context) {
  return ChatItem(
    displayName: context.knobs.string(
      label: "Display name",
      initialValue: "Sender",
    ),
    lastMessageDateTime: buildDateTime(context),
    pinned: context.knobs.boolean(label: "Pinned", initialValue: false),
  );
}

@widgetbook.UseCase(name: 'Long Text', type: ChatItem)
Widget buildLongText(BuildContext context) {
  return ChatItem(
    displayName: context.knobs.string(
      label: "Display name",
      initialValue: veryLongText,
    ),
    lastMessageDateTime: buildDateTime(context),
    pinned: context.knobs.boolean(label: "Pinned", initialValue: false),
  );
}

@widgetbook.UseCase(name: '60 days ago', type: ChatItem)
Widget buildMessage60DaysAgo(BuildContext context) {
  return ChatItem(
    displayName: context.knobs.string(
      label: "Display name",
      initialValue: veryLongText,
    ),
    lastMessageDateTime: buildDateTime(
      context,
      initialValue: DateTime.now().subtract(Duration(days: 60)),
    ),
    pinned: context.knobs.boolean(label: "Pinned", initialValue: false),
  );
}
