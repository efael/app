import 'package:flutter/widgets.dart';

class StackPage {
  final String key;
  final Widget page;
  final String iconPath;
  bool disabled;
  int notificationsCount;

  StackPage({
    required this.key,
    required this.page,
    required this.iconPath,
    this.disabled = false,
    this.notificationsCount = 0,
  });
}
