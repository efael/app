import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/widgets/username.dart';
import 'package:messenger/widgets/userpic.dart';

class ChatItem extends StatelessWidget {
  final String name;
  final String? message;

  const ChatItem({super.key, required this.name, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: consts.colors.dominant.bgHighContrast,
      height: 80,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          splashColor: consts.colors.dominant.bgMediumContrast,
          highlightColor: consts.colors.dominant.bgLowContrast,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              spacing: 12,
              children: [
                Userpic(name: name),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Username(name: name),
                          Text("08:28", style: consts.typography.text3),
                        ],
                      ),
                      Text(message ?? "-", style: consts.typography.text2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
