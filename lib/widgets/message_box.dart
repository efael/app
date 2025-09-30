import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({super.key});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 16.0),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 7,
              decoration: InputDecoration(
                border: InputBorder.none,
                hint: Text(
                  "Message",
                  style: TextStyle(
                    fontSize: 16,
                    color: consts.colors.content.mediumContrast,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 24.0,
            color: consts.colors.accent.blueSecondary,
            onPressed: () {},
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
