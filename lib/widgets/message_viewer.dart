import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:intl/intl.dart';

enum MessageStatus { sent, delivering, seen }
enum MessageDirection { incoming, outgoing }

class MessageViewer extends StatelessWidget {
  final String content;
  final DateTime time;
  final MessageStatus status;
  final MessageDirection direction;
  const MessageViewer({
    super.key,
    required this.content,
    required this.time,
    this.status = MessageStatus.sent,
    this.direction = MessageDirection.outgoing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: direction == MessageDirection.outgoing ? consts.colors.dominant.bgMediumContrast : consts.colors.accent.bluePrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: SelectableText(
                content,
                style: consts.typography.text2.copyWith(color: consts.colors.accent.white, height: 0),
              ),
            ),
          ),

          // vaqt + icon bitta blokda
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 6),
              SelectableText(
                DateFormat('HH:mm').format(time),
                style: consts.typography.text3.copyWith(
                  color: consts.colors.accent.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                status == MessageStatus.sent
                    ? Icons.done
                    : status == MessageStatus.delivering
                    ? Icons.access_time
                    : Icons.done_all,
                size: 16,
                color: consts.colors.accent.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
