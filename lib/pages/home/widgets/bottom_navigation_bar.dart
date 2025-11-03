import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:messenger/constants.dart";

import "../models/nav_item.dart";

class HomeBottomNavigationBar extends StatelessWidget {
  final String activeItemKey;
  final List<NavItem> items;
  final ValueChanged<String> onTap;

  const HomeBottomNavigationBar({
    super.key,
    required this.activeItemKey,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double height = 64.0;

    return SafeArea(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: consts.colors.dominant.bgMediumContrast.dark,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final bool selected = item.key == activeItemKey;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTap(item.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 64,
                            height: 32,
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: selected
                                  ? consts.colors.dominant.bgLowContrast.dark
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: SvgPicture.asset(
                              item.iconPath,
                              colorFilter: ColorFilter.mode(
                                selected
                                    ? consts.colors.content.highContrast.dark
                                    : consts.colors.content.mediumContrast.dark,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 14,
                            top: 2,
                            child: (item.count != null && item.count! > 0)
                                ? Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          consts.colors.accent.bluePrimary.dark,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (item.count! > 99)
                                            ? "99+"
                                            : item.count.toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? consts.colors.content.highContrast.dark
                              : consts.colors.content.mediumContrast.dark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
