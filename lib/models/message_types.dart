import "package:intl/intl.dart";
import "package:messenger/enums/message_state.dart";
import "package:messenger/enums/message_type.dart";

class BaseMessageType {
  final int id;
  final MessageType type;
  final MessageState status;
  final DateTime time;

  final int sender;
  final int? replayTo;

  BaseMessageType({
    required this.id,
    required this.type,
    required this.status,
    required this.time,
    required this.sender,
    this.replayTo,
  });

  get formatedTime => DateFormat("HH:mm").format(time);
}

class TextMessageTypes extends BaseMessageType {
  final String message;

  TextMessageTypes({
    required super.id,
    required super.type,
    required super.status,
    required super.time,
    required super.sender,
    super.replayTo,

    required this.message,
  });
}
