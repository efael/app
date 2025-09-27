import 'package:flutter/material.dart';
import 'package:messenger/src/bindings/signals/signals.dart';

class MessagePreview extends StatelessWidget {
  const MessagePreview({super.key, this.event});

  final EventTimelineItem? event;

  @override
  Widget build(BuildContext context) {
    return Text("message");
  }
}
