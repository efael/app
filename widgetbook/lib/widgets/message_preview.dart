import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:messenger/widgets/message_preview.dart';

@widgetbook.UseCase(name: 'Default', type: MessagePreview)
Widget buildCoolButtonUseCase(BuildContext context) {
  return MessagePreview();
}
