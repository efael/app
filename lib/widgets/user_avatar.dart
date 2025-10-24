import 'package:flutter/material.dart';

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
          colors: [Color(0xFF6D0EB5), Color(0xFF4059F1)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CircleAvatar(
        backgroundImage: (imagePath != null) ? AssetImage(imagePath!) : null,
        backgroundColor: Colors.transparent,
        child: (imagePath == null)
            ? FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    userInitials,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 100,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
