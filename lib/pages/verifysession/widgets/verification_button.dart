import "package:flutter/material.dart";
import "package:messenger/constants.dart";

class VerificationButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  const VerificationButton({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.black),
        fixedSize: WidgetStatePropertyAll<Size>(
          Size(
            MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width,
            48,
          ),
        ),
      ),
      child: Text(
        title,
        style: consts.typography.text2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
