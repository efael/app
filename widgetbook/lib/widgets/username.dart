import 'package:flutter/material.dart';
import 'package:messenger/widgets/username.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

Widget build(BuildContext context, bool secure, bool mute) {
  return Center(
    child: Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Username(
            name: context.knobs.string(
              label: "Name",
              initialValue: "User Name",
            ),
            secure: context.knobs.boolean(
              label: "Secure",
              initialValue: secure,
            ),
            mute: context.knobs.boolean(label: "Mute", initialValue: mute),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Secure=No, Mute=No', type: Username)
Widget buildNoSecureNoMute(BuildContext context) =>
    build(context, false, false);

@widgetbook.UseCase(name: 'Secure=Yes, Mute=No', type: Username)
Widget buildSecureNoMute(BuildContext context) => build(context, true, false);

@widgetbook.UseCase(name: 'Secure=Yes, Mute=Yes', type: Username)
Widget buildSecureMute(BuildContext context) => build(context, true, true);
