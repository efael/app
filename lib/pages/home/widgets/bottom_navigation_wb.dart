import "package:flutter/material.dart";
import "package:messenger/pages/home/widgets/bottom_navigation_bar.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "../common_wb.dart";

@widgetbook.UseCase(
  name: "Default",
  type: HomeBottomNavigationBar,
  path: "$path/widgets",
)
Widget buildUseCase(BuildContext context) {
  return HomeBottomNavigationBar(
    activeItemKey: bottomTabs.first.key,
    items: bottomTabs,
    onTap: (value) {},
  );
}
