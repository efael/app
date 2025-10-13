import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:messenger/constants.dart';
import 'package:intl/intl.dart';
import 'package:messenger/widgets/custom_popup.dart';

enum MessageStatus { sent, delivering, seen }

enum MessageDirection { incoming, outgoing }

class MessageViewer extends StatelessWidget {
  final GlobalKey targetKey = GlobalKey();
  final String content;
  final DateTime time;
  final MessageStatus status;
  final MessageDirection direction;
  final VoidCallback? onTap;

  MessageViewer({
    super.key,
    required this.content,
    required this.time,
    this.status = MessageStatus.sent,
    this.direction = MessageDirection.outgoing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      items: [
        MyPopupMenuItem(
          leading: Icon(Icons.edit, color: consts.colors.content.mediumContrast),
          title: Text(
            'Edit',
            style: consts.typography.text2.copyWith(color: consts.colors.content.highContrast),
          ),
          onTap: () => debugPrint('Edit bosildi'),
        ),
        MyPopupMenuItem(
          leading: Icon(Icons.delete, color: consts.colors.content.mediumContrast),
          title: Text(
            'Delete',
            style: consts.typography.text2.copyWith(color: consts.colors.content.highContrast),
          ),
          onTap: () => debugPrint('Delete bosildi'),
        ),
        MyPopupMenuItem(
          leading: Icon(Icons.share, color: consts.colors.content.mediumContrast),
          title: Text(
            'Share',
            style: consts.typography.text2.copyWith(color: consts.colors.content.highContrast),
          ),
          onTap: () => debugPrint('Share bosildi'),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: direction == MessageDirection.outgoing
              ? consts.colors.dominant.bgMediumContrast
              : consts.colors.accent.bluePrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  content,
                  style: consts.typography.text2.copyWith(
                    color: consts.colors.accent.white,
                    height: 0,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 6),
                Text(
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
      ),
    );
  }
}
