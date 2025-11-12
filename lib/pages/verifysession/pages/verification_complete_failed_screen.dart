import "package:flutter/material.dart";
import "package:messenger/constants.dart";
import "package:messenger/features/onboarding/common_wb.dart";
import "package:messenger/pages/verifysession/widgets/verification_button.dart";
import "package:messenger/pages/verifysession/widgets/verification_header_widget.dart";
import "package:widgetbook/widgetbook.dart";

import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

@widgetbook.UseCase(name: "Default", type: VerificationCompleteFailedScreen, path: "$path/pages")
Widget verificationCompleteFailedScreenBuilder(BuildContext context) {
  return VerificationCompleteFailedScreen(
    verificationHeaderType: context.knobs.object.dropdown(
      label: "Type",
      options: <VerificationHeaderType>[
        VerificationHeaderType.complete,
        VerificationHeaderType.failed,
      ],
      initialOption: VerificationHeaderType.complete,
      labelBuilder: (value) {
        return value.name;
      },
    ),
  );
}

class VerificationCompleteFailedScreen extends StatefulWidget {
  VerificationHeaderType verificationHeaderType;
  VerificationCompleteFailedScreen({super.key, required this.verificationHeaderType});

  @override
  State<VerificationCompleteFailedScreen> createState() => _VerificationCompleteFailedScreenState();
}

class _VerificationCompleteFailedScreenState extends State<VerificationCompleteFailedScreen> {
  final List<String> optionsText = [
    "Now you can read or send message securely on your other device.",
    "Either the request timed out, the request was denied, or there was a verification mismatch.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 70),

              VerificationHeaderWidget(verificationHeaderType: widget.verificationHeaderType),

              const SizedBox(height: 24),

              Text(
                "Verification requested",
                style: consts.typography.text1.copyWith(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                widget.verificationHeaderType == VerificationHeaderType.complete
                    ? optionsText[0]
                    : optionsText[1],
                style: consts.typography.text3.copyWith(
                  fontSize: 14,
                  color: consts.colors.content.mediumContrast.dark,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              VerificationButton(title: "Done", onPressed: () {}),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
