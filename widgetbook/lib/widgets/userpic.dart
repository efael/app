import 'package:flutter/material.dart';
import 'package:messenger/widgets/userpic.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

Widget build(BuildContext context, UserpicSize initialSize) {
  return Column(
    children: [
      Center(
        child: Userpic(
          name: context.knobs.string(label: "Name", initialValue: "User Name"),
          size: context.knobs.object.dropdown(
            label: "Size",
            labelBuilder: (value) => value.name,
            options: [UserpicSize.small, UserpicSize.medium],
            initialOption: initialSize,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Small', type: Userpic)
Widget buildSmall(BuildContext context) => build(context, UserpicSize.small);

@widgetbook.UseCase(name: 'Medium', type: Userpic)
Widget buildMedium(BuildContext context) => build(context, UserpicSize.medium);
