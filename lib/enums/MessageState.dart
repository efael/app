import 'package:flutter/material.dart';

enum MessageState { waiting, sent, read, failed }

extension extentions on MessageState {
  IconData get icon {
    switch (this) {
      case MessageState.waiting:
        return Icons.schedule;
      case MessageState.sent:
        return Icons.done;
      case MessageState.read:
        return Icons.done_all;
      case MessageState.failed:
        return Icons.warning_amber;
    }
  }
}
