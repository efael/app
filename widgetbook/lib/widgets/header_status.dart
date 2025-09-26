import 'package:flutter/material.dart';
import 'package:messenger/widgets/header_status.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: HeaderStatusTyping)
Widget build(BuildContext context) {
  return HeaderStatusTyping();
}
