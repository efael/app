import 'package:flutter/material.dart';
import 'package:messenger/widgets/message_viewer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default Message', type: MessageViewer)
Widget messageViewerUseCase(BuildContext context) {
  return Center(
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: MessageViewer(
            content: context.knobs.string(
              label: "Message",
              initialValue: "Hello, this is a sample message!",
            ),
            time: DateTime.now(),
            status: context.knobs.object.dropdown(
              label: "MessageStatus", 
              labelBuilder: (value) => value.name,
              options: [
                MessageStatus.sent,
                MessageStatus.delivering,
                MessageStatus.seen
              ]
            ),
          ),
        ),

        const SizedBox(height: 16),

        Align(
          alignment: Alignment.centerRight,
          child: MessageViewer(
            content: context.knobs.string(
              label: "Message",
              initialValue: "Hello, this is a sample message!",
            ),
            time: DateTime.now(),
            status: context.knobs.object.dropdown(
              label: "MessageStatus", 
              labelBuilder: (value) => value.name,
              options: [
                MessageStatus.sent,
                MessageStatus.delivering,
                MessageStatus.seen
              ],
            ),
            direction: MessageDirection.incoming,
          ),
        ),
      ],
    ),
  );
}
