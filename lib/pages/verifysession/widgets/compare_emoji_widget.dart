import "package:flutter/material.dart";
import "package:messenger/constants.dart";

class CompareEmojiWidget extends StatelessWidget {
  final String emoji;
  final String name;

  const CompareEmojiWidget({
    super.key,
    required this.emoji,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // MUHIM
      children: [
        Image.asset(
          emoji,
          width: 40, // Size beramiz
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            name,
            style: consts.typography.text2.copyWith(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
