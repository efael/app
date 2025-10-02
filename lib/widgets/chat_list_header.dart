import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

class ChatListHeader extends StatelessWidget {
  const ChatListHeader({super.key, required this.appName});

  final String appName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0,
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox.square(dimension: 48.0),
                Flexible(
                  child: Text(
                    appName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: consts.colors.content.highContrast,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.all(12.0),
                  iconSize: 24.0,
                  color: consts.colors.content.highContrast,
                  onPressed: () {
                    // context.pop();
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
