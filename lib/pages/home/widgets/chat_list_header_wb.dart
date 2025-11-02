import 'package:flutter/material.dart';
import 'package:messenger/pages/home/widgets/chat_list_header.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../common_wb.dart';

@widgetbook.UseCase(
  name: 'Default',
  type: ChatListHeader,
  path: "$path/widgets",
)
Widget buildUseCase(BuildContext context) {
  return NestedScrollView(
    controller: ScrollController(),
    headerSliverBuilder: (_, __) => [
      ChatListHeader(
        title: context.knobs.string(label: "Title", initialValue: "Efael"),
      ),
    ],
    body: Placeholder(),
  );
}
