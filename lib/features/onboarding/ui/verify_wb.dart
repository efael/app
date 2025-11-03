import "package:flutter/material.dart";
import "package:widgetbook/widgetbook.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

import "../common_wb.dart";
import "verify.dart";

@widgetbook.UseCase(name: "Default", type: OnboardingVerifyUI, path: "$path/ui")
Widget buildUseCase(BuildContext context) {
  return OnboardingVerifyUI(
    signOutCallback: () {},

    useAnotherDeviceEnabled: context.knobs.boolean(
      label: "Use another device enabled",
      initialValue: true,
    ),
    useAnotherDeviceCallback:
        context.knobs.boolean(
          label: "Use another device callback available",
          initialValue: true,
        )
        ? () {}
        : null,

    enterRecoveryKeyEnabled: context.knobs.boolean(
      label: "Enter recovery key enabled",
      initialValue: true,
    ),
    enterRecoveryKeyCallback:
        context.knobs.boolean(
          label: "Enter recovery key callback available",
          initialValue: true,
        )
        ? () {}
        : null,

    cantConfirmEnabled: context.knobs.boolean(
      label: "Can't confirm enabled",
      initialValue: true,
    ),
    cantConfirmCallback:
        context.knobs.boolean(
          label: "Can't confirm callback available",
          initialValue: true,
        )
        ? () {}
        : null,
  );
}
