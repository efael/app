import "package:flutter/material.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "../common_wb.dart";
import "reset_password.dart";

@widgetbook.UseCase(
  name: "Default",
  type: SecurityResetPasswordUI,
  path: "$path/ui",
)
Widget buildUseCase(BuildContext context) {
  return SecurityResetPasswordUI();
}
