import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:messenger/widgets/username.dart';

@widgetbook.UseCase(name: 'Default', type: Username)
Widget buildCoolButtonUseCase(BuildContext context) {
  return Username();
}
