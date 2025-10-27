import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';

class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final String userInitials;
  final double size;

  const UserAvatar({
    super.key,
    this.imagePath,
    required this.userInitials,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(180, 147, 248, 1),
            Color.fromRGBO(111, 99, 224, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CircleAvatar(
        backgroundImage: (imagePath != null) ? NetworkImage(imagePath!) : null,
        backgroundColor: Colors.transparent,
        child: (imagePath == null)
            ? FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    userInitials,
                    style: TextStyle(
                      color: consts.colors.accent.white.dark,
                      fontWeight: FontWeight.bold,
                      fontSize: 64,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
