import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/utils.dart';
import 'package:messenger/widgets/username.dart';

class Message extends StatelessWidget {
  const Message({
    super.key,
    this.displayName,
    required this.direction,
    required this.position,
  });

  final String? displayName;
  final MessageDirection direction;
  final MessagePosition position;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

enum MessageDirection { me, single, group }

enum MessagePosition { onnest, first, middle, last }

class MessageText extends Message {
  const MessageText({
    super.key,
    super.displayName,
    required super.direction,
    required super.position,

    required this.text,
    required this.sentAt,
  });

  final String text;
  final DateTime sentAt;

  Radius get fullRadius => Radius.circular(16.0);
  Radius get halfRadius => Radius.circular(8.0);
  BorderRadius get fullBorderRadius => BorderRadius.all(fullRadius);

  BorderRadius get containerBorderRadius => switch (direction) {
    MessageDirection.me => switch (position) {
      MessagePosition.onnest => fullBorderRadius,
      MessagePosition.first => fullBorderRadius.copyWith(
        bottomRight: halfRadius,
      ),
      MessagePosition.middle => fullBorderRadius.copyWith(
        topRight: halfRadius,
        bottomRight: halfRadius,
      ),
      MessagePosition.last => fullBorderRadius.copyWith(topRight: halfRadius),
    },
    _ => switch (position) {
      MessagePosition.onnest => fullBorderRadius,
      MessagePosition.first => fullBorderRadius.copyWith(
        bottomLeft: halfRadius,
      ),
      MessagePosition.middle => fullBorderRadius.copyWith(
        topLeft: halfRadius,
        bottomLeft: halfRadius,
      ),
      MessagePosition.last => fullBorderRadius.copyWith(topLeft: halfRadius),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (direction == MessageDirection.me)
          Expanded(child: SizedBox.shrink()),
        Container(
          constraints: BoxConstraints(
            minWidth: 100,
            maxWidth: MediaQuery.of(context).size.width * 0.65,
          ),
          decoration: BoxDecoration(
            borderRadius: containerBorderRadius,
            color: direction == MessageDirection.me
                ? consts.colors.accent.bluePrimary
                : consts.colors.dominant.bgMediumContrast,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    if (displayName != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 6.0,
                          left: 12.0,
                          right: 12.0,
                        ),
                        child: Username(
                          name: displayName!,
                          size: UsernameSize.small,
                        ),
                      ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: consts.colors.accent.white,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                    // TODO: fix alignment, add reactions
                    Container(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        right: 12.0,
                        bottom: 12.0,
                      ),
                      child: Text(
                        hourMinuteFormatter.format(sentAt),
                        style: TextStyle(
                          fontSize: 11.0,
                          color: consts.colors.content.highContrast.withValues(
                            alpha: 0.65 * 256.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (direction != MessageDirection.me)
          Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
