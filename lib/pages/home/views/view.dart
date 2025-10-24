import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/widgets/CustomBottomNavigationBar.dart';

import '../controllers/controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.findTabIndexByActiveTabKey(controller.activeTabKey.value),
          children: controller.pageTabs.map((item) => item.page).toList(),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          activeItemColor: Colors.white,
          activeItemBg: Color(0xFF314356),
          inactiveItemColor: Color(0xFF6C808C),
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
