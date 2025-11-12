import "package:flutter/material.dart";
import "package:messenger/constants.dart";

class VerificationEmailItem extends StatelessWidget {
  VerificationUserEmail model;
  VerificationEmailItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width > 400
        ? 400
        : MediaQuery.of(context).size.width;

    return Container(
      width: width,
      decoration: BoxDecoration(color: Color(0xfff0f2f5), borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xffffefe4),
            child: Text(
              model.name.isNotEmpty ? model.name.substring(0, 1) : "",
              style: consts.typography.text1.copyWith(
                color: Color(0xff9f2c0b),
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: consts.typography.text2.copyWith(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),

                Text(
                  model.email,
                  style: consts.typography.text3.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationUserEmail {
  final String name;
  final String email;

  VerificationUserEmail({required this.name, required this.email});
}
