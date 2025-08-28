import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:messenger/widgets/userpic.dart';

@widgetbook.UseCase(name: 'Default', type: Userpic)
Widget buildCoolButtonUseCase(BuildContext context) {
  return Userpic();
}
