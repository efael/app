import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:messenger/constants.dart";
import "package:messenger/features/onboarding/common_wb.dart";
import "package:messenger/pages/verifysession/widgets/verification_button.dart";
import "package:messenger/pages/verifysession/widgets/verification_device_item.dart";
import "package:messenger/pages/verifysession/widgets/verification_email_item.dart";
import "package:messenger/pages/verifysession/widgets/verification_header_widget.dart";
import "package:widgetbook/widgetbook.dart";
import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

@widgetbook.UseCase(name: "Default", type: IncomingVerificationScreen, path: "$path/pages")
Widget buildUseCase(BuildContext context) {
  return IncomingVerificationScreen(
    verificationHeaderType: context.knobs.object.dropdown(
      label: "Incoming Verification Header Type",
      options: VerificationHeaderType.values,
      initialOption: VerificationHeaderType.lock,
      labelBuilder: (value) {
        return value.name;
      },
    ),
  );
}

class IncomingVerificationScreen extends StatefulWidget {
  VerificationHeaderType verificationHeaderType;
  IncomingVerificationScreen({super.key, required this.verificationHeaderType});

  @override
  State<IncomingVerificationScreen> createState() => _IncomingVerificationScreenState();
}

class _IncomingVerificationScreenState extends State<IncomingVerificationScreen> {
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

              Builder(
                builder: (context) {
                  if (widget.verificationHeaderType == VerificationHeaderType.user) {
                    return VerificationEmailItem(
                      model: VerificationUserEmail(name: "Alice", email: "@alice:example.com"),
                    );
                  } else {
                    return VerificationDeviceItem(
                      model: VerificationDeviceUIModel(
                        name: "Element X Android",
                        date: DateFormat("hh:mm").format(DateTime.now()),
                        deviceId: "ILAKNDNASDLK",
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              if (widget.verificationHeaderType != VerificationHeaderType.user)
                Text(
                  "Only continue if you initiated this verification.",
                  style: consts.typography.text2.copyWith(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),

              Spacer(),

              if (widget.verificationHeaderType != VerificationHeaderType.loading)
                VerificationButton(title: "Start verification"),

              if (widget.verificationHeaderType != VerificationHeaderType.loading)
                const SizedBox(height: 12),

              if (widget.verificationHeaderType != VerificationHeaderType.loading)
                TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    fixedSize: WidgetStatePropertyAll<Size>(
                      Size(
                        MediaQuery.of(context).size.width > 600
                            ? 600
                            : MediaQuery.of(context).size.width,
                        48,
                      ),
                    ),
                  ),
                  child: Text(
                    "Ignore",
                    style: consts.typography.text2.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
