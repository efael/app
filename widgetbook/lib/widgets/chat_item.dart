import 'package:flutter/material.dart';
import 'package:messenger/widgets/chat_item.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: ChatItem)
Widget build(BuildContext context) {
  return ChatItem();
}
