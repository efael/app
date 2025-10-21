import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final String userInitials;
  final double size;

  const UserAvatar({super.key, this.imagePath, required this.userInitials, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.size,
      height: this.size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF6D0EB5), Color(0xFF4059F1)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CircleAvatar(
        backgroundImage: (this.imagePath != null) ? AssetImage(this.imagePath!) : null,
        backgroundColor: Colors.transparent,
        child: (this.imagePath == null)
            ? Text(this.userInitials, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22))
            : null,
      ),
    );
  }
}
