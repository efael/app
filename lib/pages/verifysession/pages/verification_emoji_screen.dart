import "package:flutter/material.dart";
import "package:messenger/constants.dart";
import "package:messenger/features/onboarding/common_wb.dart";
import "package:messenger/pages/verifysession/widgets/compare_emoji_widget.dart";
import "package:messenger/pages/verifysession/widgets/verification_button.dart";
import "package:messenger/pages/verifysession/widgets/verification_header_widget.dart";
import "package:messenger/pages/verifysession/widgets/verification_text_button.dart";
import "package:widgetbook/widgetbook.dart";

import "package:widgetbook_annotation/widgetbook_annotation.dart" as widgetbook;

@widgetbook.UseCase(name: "Default", type: VerificationEmojiScreen, path: "$path/pages")
Widget verificationEmojiCompareScreen(BuildContext context) {
  return VerificationEmojiScreen(
    verificationCompareType: context.knobs.object.dropdown(
      label: "compare type",
      options: VerificationCompareType.values,
      initialOption: VerificationCompareType.emoji,
      labelBuilder: (value) => value.name,
    ),
    verificationHeaderType: context.knobs.object.dropdown(
      label: "type",
      options: VerificationHeaderType.values,
      initialOption: VerificationHeaderType.lock,
      labelBuilder: (value) => value.name,
    ),
  );
}

class VerificationEmojiScreen extends StatefulWidget {
  final VerificationCompareType verificationCompareType;
  final VerificationHeaderType verificationHeaderType;
  const VerificationEmojiScreen({
    super.key,
    required this.verificationCompareType,
    required this.verificationHeaderType,
  });

  @override
  State<VerificationEmojiScreen> createState() => VerificationEmojiScreenState();
}

class VerificationEmojiScreenState extends State<VerificationEmojiScreen> {
  final List<String> _emojis = [
    "assets/icons/pizza.png",
    "assets/icons/rocket.png",
    "assets/icons/rocket.png",
    "assets/icons/book.png",
    "assets/icons/hammer.png",
    "assets/icons/hammer.png",
    "assets/icons/pin.png",
    "assets/icons/pizza.png",
  ];

  final List<String> _emojisName = [
    "Pizza",
    "Rocket",
    "Rocket",
    "Book",
    "Hammer",
    "Hammer",
    "Pin",
    "Pizza",
  ];

  int activeEmojiIndex = -1;

  final List<String> _optionText = [
    "Confirm that the emojis below math those shown on your other devices.",
    "Confirm that the numbers below math those shown on your other devices.",
  ];

  @override
  Widget build(BuildContext context) {
    final double gridWidth = MediaQuery.of(context).size.width > 400
        ? 400
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 70),

              VerificationHeaderWidget(verificationHeaderType: widget.verificationHeaderType),

              const SizedBox(height: 24),

              Text(
                widget.verificationCompareType == VerificationCompareType.emoji
                    ? "Compare emojis"
                    : "Compare numbers",
                style: consts.typography.text1.copyWith(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                widget.verificationCompareType == VerificationCompareType.emoji
                    ? _optionText[0]
                    : _optionText[1],
                style: consts.typography.text3.copyWith(
                  fontSize: 14,
                  color: consts.colors.content.mediumContrast.dark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 56),

              Builder(
                builder: (context) {
                  if (widget.verificationCompareType == VerificationCompareType.number) {
                    return Text(
                      _addDashEvery3Digits(
                        context.knobs.string(label: "Number", initialValue: "123456789"),
                      ),
                      style: consts.typography.text1.copyWith(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  }

                  return SizedBox(
                    width: gridWidth,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        // childAspectRatio: 1 / 1,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _emojis.length,
                      itemBuilder: (context, index) {
                        return CompareEmojiWidget(emoji: _emojis[index], name: _emojisName[index]);
                      },
                    ),
                  );
                },
              ),

              const Spacer(),

              VerificationButton(title: "They match", onPressed: () {}),
              const SizedBox(height: 12),
              VerificationTextButton(title: "Ignore", onPressed: () {}),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

enum VerificationCompareType { emoji, number }

String _addDashEvery3Digits(String number) {
  final buffer = StringBuffer();
  int count = 0;

  for (int i = number.length - 1; i >= 0; i--) {
    buffer.write(number[i]);
    count++;

    if (count % 3 == 0 && i != 0) {
      buffer.write("-");
    }
  }

  return buffer.toString().split("").reversed.join();
}
