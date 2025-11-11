import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

enum VerificationHeaderType { lock, user, loading }

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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color(0xfff0f2f5)),
      alignment: Alignment.center,
      child: Builder(
        builder: (context) {
          if (verificationHeaderType == VerificationHeaderType.lock) {
            return Icon(CupertinoIcons.lock_fill, size: iconSize, color: iconColor,);
          } else if (verificationHeaderType == VerificationHeaderType.user) {
            return Icon(Icons.account_circle, size: iconSize, color: iconColor,);
          } else {
            return  SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                color: iconColor,
              ),
            );
          }
        },
      ),
    );
  }
}
