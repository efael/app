import 'package:flutter/material.dart';
import 'package:messenger/widgets/message_preview.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: MessagePreview)
Widget build(BuildContext context) {
  return MessagePreview();
}
