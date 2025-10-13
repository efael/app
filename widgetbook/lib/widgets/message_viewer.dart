import 'package:flutter/material.dart';
import 'package:messenger/widgets/message_viewer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default Message', type: MessageViewer)
Widget messageViewerUseCase(BuildContext context) {
  final GlobalKey messageKey = GlobalKey();
  final GlobalKey messageKey2 = GlobalKey();
  return Center(
    child: Column(
      children: [
        const SizedBox(height: 400),

        Align(
          alignment: Alignment.centerLeft,
          child: MessageViewer(
            key: messageKey,
            content: context.knobs.string(
              label: "Message",
              initialValue: "Hello, this is a sample message!",
            ),
            time: DateTime.now(),
            status: context.knobs.object.dropdown(
              label: "MessageStatus",
              labelBuilder: (value) => value.name,
              options: [MessageStatus.sent, MessageStatus.delivering, MessageStatus.seen],
            ),
            onTap: () {
              
            },
          ),
        ),

        Align(
          alignment: Alignment.centerRight,
          child: MessageViewer(
            key: messageKey2,
            direction: MessageDirection.incoming,
            content: context.knobs.string(
              label: "Message",
              initialValue: "Hello, this is a sample message!",
            ),
            time: DateTime.now(),
            status: context.knobs.object.dropdown(
              label: "MessageStatus",
              labelBuilder: (value) => value.name,
              options: [MessageStatus.sent, MessageStatus.delivering, MessageStatus.seen],
            ),
            onTap: () {
              // print("Message tapped");
              // CustomPopover.show(
              //   context: context,
              //   targetKey: messageKey2,
              //   child: MessagePopupMenu(),
              //   moveToLeft: 300
              // );
            },
          ),
        ),
      ],
    ),
  );
}
