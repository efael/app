import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

enum UsernameSize {
  small,
  medium,
  large;

  double get fontSize => switch (this) {
    UsernameSize.small => 15.0,
    UsernameSize.medium => 16.0,
    UsernameSize.large => 20.0,
  };
}

class Username extends StatelessWidget {
  const Username({
    super.key,
    this.size = UsernameSize.medium,
    required this.name,
    this.secure = false,
    this.mute = false,
  });

  final UsernameSize size;
  final String name;
  final bool secure;
  final bool mute;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              fontSize: size.fontSize,
              fontWeight: FontWeight.w500,
              color: secure
                  ? consts.colors.accent.green
                  : consts.colors.content.highContrast,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
