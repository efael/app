import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomPopupMenuItem extends StatelessWidget {
  final String icon;
  final String label;

  const CustomPopupMenuItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 16, left: 5),
          child: SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
