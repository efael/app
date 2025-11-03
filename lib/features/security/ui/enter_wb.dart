import "package:flutter/material.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "../common_wb.dart";
import "enter.dart";

@widgetbook.UseCase(name: "Default", type: SecurityEnterUI, path: "$path/ui")
Widget buildUseCase(BuildContext context) {
  return SecurityEnterUI();
}
