import "package:flutter/material.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "../common_wb.dart";
import "reset.dart";

@widgetbook.UseCase(name: "Default", type: SecurityResetUI, path: "$path/ui")
Widget buildUseCase(BuildContext context) {
  return SecurityResetUI(backCallback: () {}, resetCallback: () {});
}
