import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

enum VerificationHeaderType { lock, user, loading, emoji, complete, failed }

class VerificationHeaderWidget extends StatelessWidget {
  final VerificationHeaderType verificationHeaderType;
  const VerificationHeaderWidget({super.key, required this.verificationHeaderType});

  @override
  Widget build(BuildContext context) {
    double size = (MediaQuery.of(context).size.width / 6.5) < 60
        ? 60
        : MediaQuery.of(context).size.width / 6.5;

    size = size > 100 ? 100 : size;

    double iconSize = size / 1.8;
    Color iconColor = Color(0xff656d77);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: verificationHeaderType == VerificationHeaderType.complete
            ? Color(0xfff1fbf6)
            : verificationHeaderType == VerificationHeaderType.failed
            ? Color(0xfffff7f6)
            : Color(0xfff0f2f5),
      ),
      alignment: Alignment.center,
      child: Builder(
        builder: (context) {
          if (verificationHeaderType == VerificationHeaderType.lock) {
            return Icon(CupertinoIcons.lock_fill, size: iconSize, color: iconColor);
          } else if (verificationHeaderType == VerificationHeaderType.user) {
            return Icon(Icons.account_circle, size: iconSize, color: iconColor);
          } else if (verificationHeaderType == VerificationHeaderType.emoji) {
            return Icon(CupertinoIcons.smiley, size: iconSize, color: iconColor);
          } else if (verificationHeaderType == VerificationHeaderType.complete) {
            return Icon(
              CupertinoIcons.checkmark_circle_fill,
              size: iconSize,
              color: Color(0xff007a61),
            );
          } else if (verificationHeaderType == VerificationHeaderType.failed) {
            return Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              size: iconSize,
              color: Color(0xffd51928),
            );
          } else {
            return SizedBox(
              width: iconSize - 5,
              height: iconSize - 5,
              child: CircularProgressIndicator(color: iconColor),
            );
          }
        },
      ),
    );
  }
}
