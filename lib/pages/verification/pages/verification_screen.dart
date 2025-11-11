import "package:flutter/material.dart";
import "package:messenger/features/onboarding/common_wb.dart";
import "package:messenger/pages/verification/widgets/verification_header_widget.dart";
import "package:widgetbook/widgetbook.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

@widgetbook.UseCase(name: "Default", type: VerificationScreen, path: "$path/pages")
Widget buildUseCase(BuildContext context) {
  return VerificationScreen(
    verificationHeaderType: context.knobs.object.dropdown(
      label: "Verification Header Type",
      options: VerificationHeaderType.values,
      initialOption: VerificationHeaderType.lock,
      labelBuilder: (value) {
        return value.name;
      },
    ),
  );
}

class VerificationScreen extends StatefulWidget {
  VerificationHeaderType verificationHeaderType = VerificationHeaderType.loading;
  VerificationScreen({super.key, required this.verificationHeaderType});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          VerificationHeaderWidget(verificationHeaderType: widget.verificationHeaderType),
        ],
      ),
    );
  }
}
