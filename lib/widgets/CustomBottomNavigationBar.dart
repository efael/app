import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavItem {
  final String key;
  final String label;
  final String iconPath;
  final int? count;

  const NavItem({required this.key, required this.label, required this.iconPath, this.count});
}

class CustomBottomNavigationBar extends StatelessWidget {
  final String activeItemKey;
  final List<NavItem> items;
  final ValueChanged<String> onTap;
  final Color activeItemColor;
  final Color activeItemBg;
  final Color inactiveItemColor;

  const CustomBottomNavigationBar({
    super.key,
    required this.activeItemKey,
    required this.items,
    required this.onTap,
    required this.activeItemColor,
    required this.activeItemBg,
    required this.inactiveItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double height = 64.0;

    return SafeArea(
      child: Container(
        height: height,
        decoration: BoxDecoration(color: theme.colorScheme.surface),
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
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
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
                              color: selected ? activeItemBg : Colors.transparent,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: SvgPicture.asset(
                              item.iconPath,
                              colorFilter: ColorFilter.mode(
                                selected ? activeItemColor : inactiveItemColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 14,
                            top: 2,
                            child: (item.count != null && item.count! > 0)
                                ? Container(
                                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                    padding: EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (item.count! > 99) ? "99+" : item.count.toString(),
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                          color: selected ? activeItemColor : inactiveItemColor,
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
