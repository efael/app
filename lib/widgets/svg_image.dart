import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImage extends StatelessWidget {
  final String path;
  final Color? color;

  const SvgImage(this.path, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      colorFilter: (color != null)
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
