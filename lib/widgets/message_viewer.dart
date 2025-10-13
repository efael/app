import 'package:flutter/material.dart' hide PopupMenuItem;
import 'package:messenger/constants.dart';
import 'package:intl/intl.dart';
import 'package:messenger/widgets/custom_popup.dart';

enum MessageStatus { sent, delivering, seen }

enum MessageDirection { incoming, outgoing }

enum MessageActions { edit, delete, share, copy }

class MessageViewer extends StatelessWidget {
  final GlobalKey targetKey = GlobalKey();
  final String content;
  final DateTime time;
  final MessageStatus status;
  final MessageDirection direction;
  final VoidCallback? onTap;
  final Function(MessageActions action)? onAction;
  List<({MessageActions action, IconData icon, String label})> actions;

  MessageViewer({
    super.key,
    required this.content,
    required this.time,
    this.status = MessageStatus.sent,
    this.direction = MessageDirection.outgoing,
    this.onTap,
    this.onAction,
    this.actions = const [
      (icon: Icons.edit, label: 'Edit', action: MessageActions.edit),
      (icon: Icons.delete, label: 'Delete', action: MessageActions.delete),
      (icon: Icons.share, label: 'Share', action: MessageActions.share),
      (icon: Icons.copy, label: 'Copy', action: MessageActions.copy),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPopupMenu(
      items: actions.map((a) {
        return MyPopupMenuItem(
          leading: Icon(a.icon, color: consts.colors.content.mediumContrast),
          title: Text(
            a.label,
            style: consts.typography.text2.copyWith(color: consts.colors.content.highContrast),
          ),
          onTap: () {
            debugPrint('${a.label} bosildi');
            onAction?.call(a.action);
          },
        );
      }).toList(),
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
