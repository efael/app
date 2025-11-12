import "package:flutter/material.dart";
import "package:messenger/constants.dart";

class VerificationTextButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  const VerificationTextButton({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll<Size>(
          Size(
            MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width,
            48,
          ),
        ),
      ),
      child: Text(
        title,
        style: consts.typography.text2.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
