import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/widgets/username.dart';
import 'package:messenger/widgets/userpic.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.userName,
    this.onBackTap,
    this.onSearchTap,
  });

  final String userName;
  final GestureTapCallback? onBackTap;
  final GestureTapCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0,
      color: consts.colors.dominant.bgMediumContrast,
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 24.0,
            color: consts.colors.content.highContrast,
            onPressed: onBackTap,
            icon: Icon(Icons.arrow_back),
          ),
          Expanded(
            child: Row(
              spacing: 12.0,
              children: [
                Userpic(name: userName),
                Flexible(
                  child: Username(size: UsernameSize.large, name: userName),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.all(16.0),
            iconSize: 24.0,
            color: consts.colors.content.highContrast,
            onPressed: onSearchTap,
            icon: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
