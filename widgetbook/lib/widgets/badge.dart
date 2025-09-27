import 'package:flutter/material.dart';
import 'package:messenger/widgets/badge.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: BadgePin)
Widget build(BuildContext context) {
  return BadgePin();
}
