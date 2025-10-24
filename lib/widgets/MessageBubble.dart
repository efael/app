import 'package:flutter/material.dart';
import 'package:messenger/enums/MessageState.dart';
import 'package:messenger/models/MessageTypes.dart';

class MessageBubble extends StatelessWidget {
  final BaseMessageType model;
  final Widget child;

  const MessageBubble({super.key, required this.model, required this.child});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth * .75;

    final bool fromMe = model.sender == 777;

    return Align(
      alignment: (fromMe) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: (fromMe) ? Colors.blue : Color(0xFF212F3F),
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
                Text(model.formatedTime, style: TextStyle(color: Colors.white, fontSize: 10)),
                SizedBox(width: 4),
                (fromMe) ? Icon(model.status.icon, size: 14,) : SizedBox()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
