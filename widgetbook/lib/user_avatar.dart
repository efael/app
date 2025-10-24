import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:messenger/widgets/UserAvatar.dart';

@widgetbook.UseCase(name: 'Default', type: UserAvatar)
Widget buildUseCase(BuildContext context) {
  return UserAvatar(
    userInitials: context.knobs.string(
      label: "User Initials",
      initialValue: "TU",
    ),
  );
}
