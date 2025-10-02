import 'package:flutter/material.dart';
import 'package:messenger/widgets/message.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: Message)
Widget build(BuildContext context) {
  return Message();
}
