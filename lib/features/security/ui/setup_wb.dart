import "package:flutter/material.dart";
import "package:widgetbook/widgetbook.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "../common_wb.dart";
import "setup.dart";

@widgetbook.UseCase(name: "Default", type: SecuritySetupUI, path: "$path/ui")
Widget buildUseCase(BuildContext context) {
  return SecuritySetupUI(
    backCallback: () {},
    copyKeysCallback: () {},
    generateRecoveryKeyCallback: () {},
    generating: context.knobs.boolean(label: "Generating", initialValue: false),
    keys: context.knobs.boolean(label: "Show keys", initialValue: false)
        ? "Estm dfyU adhD h8y6 Estm dfyU adhD h8y6 Estm dfyU adhD h8y6"
        : null,
    saveRecoveryKeyCallback: () {},
    doneCallback: () {},
  );
}
