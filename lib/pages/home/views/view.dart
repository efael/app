import "package:flutter/material.dart";
import "package:get/get.dart";

import "../controllers/controller.dart";
import "../models/nav_item.dart";
import "../widgets/bottom_navigation_bar.dart";

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.findTabIndexByActiveTabKey(
            controller.activeTabKey.value,
          ),
          children: controller.pageTabs.map((item) => item.page).toList(),
        ),
        bottomNavigationBar: HomeBottomNavigationBar(
          items: controller.pageTabs
              .where((it) => !it.disabled)
              .map(
                (it) => NavItem(
                  key: it.key,
                  label: it.key.tr,
                  iconPath: it.iconPath,
                  count: it.notificationsCount,
                ),
              )
              .toList(),
          activeItemKey: controller.activeTabKey.value,
          onTap: (key) {
            controller.scrollToTop(key);
            controller.activeTabKey.value = key;
          },
        ),
      ),
    );
  }
}
