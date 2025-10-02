import 'package:flutter/material.dart';
import 'package:messenger/widgets/badge.dart';
import 'package:messenger/widgets/badge.dart' as badge;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'BadgePin', type: badge.Badge)
Widget buildBadgePin(BuildContext context) {
  return BadgePin();
}

@widgetbook.UseCase(name: 'BadgeMention', type: badge.Badge)
Widget buildBadgeMention(BuildContext context) {
  return BadgeMention();
}

@widgetbook.UseCase(name: 'BadgeAttach', type: badge.Badge)
Widget buildBadgeAttach(BuildContext context) {
  return BadgeAttach();
}

@widgetbook.UseCase(name: 'BadgeAudio', type: badge.Badge)
Widget buildBadgeAudio(BuildContext context) {
  return BadgeAudio();
}

@widgetbook.UseCase(name: 'BadgePause', type: badge.Badge)
Widget buildBadgePause(BuildContext context) {
  return BadgePause();
}

@widgetbook.UseCase(name: 'BadgeForward', type: badge.Badge)
Widget buildBadgeForward(BuildContext context) {
  return BadgeForward();
}

@widgetbook.UseCase(name: 'BadgeBackward', type: badge.Badge)
Widget buildBadgeBackward(BuildContext context) {
  return BadgeBackward();
}

@widgetbook.UseCase(name: 'BadgeSkip', type: badge.Badge)
Widget buildBadgeSkip(BuildContext context) {
  return BadgeSkip();
}

@widgetbook.UseCase(name: 'BadgePrev', type: badge.Badge)
Widget buildBadgePrev(BuildContext context) {
  return BadgePrev();
}

@widgetbook.UseCase(name: 'BadgeWallet', type: badge.Badge)
Widget buildBadgeWallet(BuildContext context) {
  return BadgeWallet();
}

@widgetbook.UseCase(name: 'BadgeLocation', type: badge.Badge)
Widget buildBadgeLocation(BuildContext context) {
  return BadgeLocation();
}

@widgetbook.UseCase(name: 'BadgeVideoMessage', type: badge.Badge)
Widget buildBadgeVideoMessage(BuildContext context) {
  return BadgeVideoMessage();
}

@widgetbook.UseCase(name: 'BadgeReorder', type: badge.Badge)
Widget buildBadgeReorder(BuildContext context) {
  return BadgeReorder();
}

@widgetbook.UseCase(name: 'BadgeCount', type: badge.Badge)
Widget buildBadgeCount(BuildContext context) {
  return BadgeCount();
}
