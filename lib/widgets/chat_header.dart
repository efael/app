import 'package:flutter/material.dart';
import 'package:messenger/widgets/username.dart';
import 'package:messenger/widgets/userpic.dart';
import 'package:go_router/go_router.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64.0,
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 24.0,
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Row(
              spacing: 12.0,
              children: [
                Userpic(name: "Hey"),
                Username(size: UsernameSize.large, name: "Hey"),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 24.0,
            onPressed: () {
              // context.pop();
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
