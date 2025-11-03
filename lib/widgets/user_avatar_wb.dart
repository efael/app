import "package:flutter/material.dart";
import "package:messenger/rinf/bindings/signals/signals.dart";
import "package:widgetbook/widgetbook.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "package:messenger/widgets/user_avatar.dart";

@widgetbook.UseCase(name: "Default", type: UserAvatar)
Widget buildUseCase(BuildContext context) {
  return UserAvatar(
    avatar: RoomPreviewAvatarText(
      value: context.knobs.string(label: "User Initials", initialValue: "TU"),
    ),
    size: context.knobs.int
        .slider(label: "Size", min: 12, max: 96, initialValue: 24)
        .toDouble(),
  );
}
