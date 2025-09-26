import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

class Username extends StatelessWidget {
  const Username({
    super.key,
    required this.name,
    this.secure = false,
    this.mute = false,
  });

  final String name;
  final bool secure;
  final bool mute;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: consts.typography.text1.copyWith(
            color: secure
                ? consts.colors.accent.green
                : consts.colors.content.highContrast,
          ),
        ),
      ],
    );
  }
}
