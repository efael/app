import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:get/get.dart";
import "package:messenger/constants.dart";

class ChatList extends StatelessWidget {
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  const ChatList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return (itemCount != 0)
        ? Container(
            color: consts.colors.dominant.bgHighContrast.dark,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: itemCount,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  color: consts.colors.dominant.bgLowContrast.dark,
                  height: 1,
                  thickness: 1,
                );
              },
              itemBuilder: itemBuilder,
            ),
          )
        : Container(
            color: consts.colors.dominant.bgHighContrast.dark,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/folder.svg",
                    width: 128,
                    height: 128,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  Text(
                    "empty".tr,
                    style: consts.typography.text1.copyWith(fontSize: 24),
                  ),
                ],
              ),
            ),
          );
  }
}
