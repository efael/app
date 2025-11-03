import "package:flutter/material.dart";
import "package:messenger/constants.dart";
import "package:messenger/rinf/bindings/bindings.dart";

class MessageBubble extends StatelessWidget {
  final Profile profile;
  final Widget child;
  final String sentAt;
  final bool sentByCurrentUser;

  const MessageBubble({
    super.key,
    required this.profile,
    required this.child,
    required this.sentAt,
    required this.sentByCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth * .75;

    return Align(
      alignment: (sentByCurrentUser)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(minWidth: 80, maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: (sentByCurrentUser)
              ? consts.colors.accent.bluePrimary.dark
              : consts.colors.dominant.bgMediumContrast.dark,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            child,
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sentAt,
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                SizedBox(width: 4),
                // (fromMe) ? Icon(model.status.icon, size: 14) : SizedBox(),
                (sentByCurrentUser) ? SizedBox() : SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
