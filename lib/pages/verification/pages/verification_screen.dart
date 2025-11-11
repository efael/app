import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:messenger/constants.dart";
import "package:messenger/features/onboarding/common_wb.dart";
import "package:messenger/pages/verification/widgets/verification_device_item.dart";
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
  final List<String> optionsText = [
    "Verfy the other device to keep your message history secure",
    "Fox extra security, another user wants to verify your identity. You'll be shown a sent of emojis to compare.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),

              VerificationHeaderWidget(verificationHeaderType: widget.verificationHeaderType),

              const SizedBox(height: 24),

              Text(
                "Verification requested",
                style: consts.typography.text1.copyWith(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.verificationHeaderType != VerificationHeaderType.user
                    ? optionsText[0]
                    : optionsText[1],
                style: consts.typography.text3.copyWith(
                  fontSize: 14,
                  color: consts.colors.content.mediumContrast.dark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              VerificationDeviceItem(
                model: VerificationDeviceUIModel(
                  name: "Element X Android",
                  date: DateFormat("hh:mm").format(DateTime.now()),
                  deviceId: "ILAKNDNASDLK",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
