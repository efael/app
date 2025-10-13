import 'package:flutter/material.dart';

class CustomInkwell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final ShapeBorder? shape;
  const CustomInkwell({super.key, required this.child, this.onTap, this.shape});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
