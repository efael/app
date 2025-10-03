import 'package:flutter/material.dart';
import 'package:messenger/widgets/message.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/helpers/very_long_text.dart';

@widgetbook.UseCase(name: 'Message Text', type: Message)
Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: MessageText(
      displayName: context.knobs.stringOrNull(
        label: "Display name",
        initialValue: "Ali",
      ),
      text: context.knobs.string(label: "Text", initialValue: veryLongText),
      direction: context.knobs.object.dropdown(
        label: "Direction",
        labelBuilder: (value) => value.name,
        options: [
          MessageDirection.me,
          MessageDirection.single,
          MessageDirection.group,
        ],
        initialOption: MessageDirection.me,
      ),
      position: context.knobs.object.dropdown(
        label: "Position",
        labelBuilder: (value) => value.name,
        options: [
          MessagePosition.onnest,
          MessagePosition.first,
          MessagePosition.middle,
          MessagePosition.last,
        ],
        initialOption: MessagePosition.onnest,
      ),
      sentAt: context.knobs.dateTime(
        label: "Sent at",
        initialValue: DateTime.now(),
        start: DateTime.now().subtract(const Duration(days: 365 * 10)),
        end: DateTime.now(),
      ),
    ),
  );
}
