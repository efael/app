import 'package:flutter/material.dart';
import 'package:messenger/widgets/message_box.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: MessageBox)
Widget build(BuildContext context) {
  return MessageBox();
}
