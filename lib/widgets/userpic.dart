import 'package:flutter/material.dart';

enum UserpicSize {
  small,
  medium,
  large;

  double get height => switch (this) {
    UserpicSize.small => 34.0,
    UserpicSize.medium => 48.0,
    UserpicSize.large => 56.0,
  };

  double get width => switch (this) {
    UserpicSize.small => 34.0,
    UserpicSize.medium => 48.0,
    UserpicSize.large => 56.0,
  };

  double get fontSize => switch (this) {
    UserpicSize.small => 12.0,
    UserpicSize.medium => 22.0,
    UserpicSize.large => 56.0,
  };
}

class Userpic extends StatelessWidget {
  const Userpic({
    super.key,
    this.size = UserpicSize.medium,
    required this.name,
  });

  final UserpicSize size;
  final String name;

  String get nameInitials {
    final initials = name.split(" ").take(2).map((name) {
      if (name.isEmpty) {
        return "";
      }

      return name[0].toUpperCase();
    }).join();

    if (initials.isEmpty) {
      return "U";
    }

    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size.height)),
        color: Colors.red,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(180, 147, 248, 1),
            Color.fromRGBO(111, 99, 224, 1),
          ],
          begin: AlignmentGeometry.topCenter,
          end: AlignmentGeometry.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(
          nameInitials,
          style: TextStyle(
            fontSize: size.fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
