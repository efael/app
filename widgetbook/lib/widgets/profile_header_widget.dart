import 'package:flutter/material.dart';
import 'package:messenger/widgets/profile_header_widget.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

Widget profileHeaderUseCase(
  BuildContext context, {
  bool isHaveAvatar = false,
  bool isOnline = false,
  bool isWrite =  false,
}) {
  return Align(
    alignment: Alignment.topCenter,
    child: ProfileHeaderWidget(
      name: context.knobs.string(
        label: "Message",
        initialValue: "Kirill Karmanov",
      ),
      avatarUrl: "assets/images/img_profile.jpg",
      isHaveAvatar: context.knobs.boolean(label: "IsHaveAvatar", initialValue: isHaveAvatar),
      isOnline: context.knobs.boolean(label: "IsOnline", initialValue: isOnline),
      isSecret: context.knobs.boolean(label: "IsSecret", initialValue: false),
      isWrite: context.knobs.boolean(label: "IsWrite", initialValue: isWrite),
    ),
  );
}

@widgetbook.UseCase(name: 'Avater=No, Online=No', type: ProfileHeaderWidget)
Widget profileHeaderAllCase(BuildContext context) =>
    profileHeaderUseCase(context, isHaveAvatar: false, isOnline: false, );
