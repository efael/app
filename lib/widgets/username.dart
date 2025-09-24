import 'package:flutter/material.dart';

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
          style: TextStyle(
            color: secure ? Color.fromRGBO(42, 157, 99, 1) : Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
