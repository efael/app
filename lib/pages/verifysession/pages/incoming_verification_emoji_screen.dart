import "package:flutter/material.dart";
import "package:messenger/constants.dart";
import "package:messenger/features/onboarding/common_wb.dart";
import "package:messenger/pages/verifysession/widgets/verification_header_widget.dart";

@widgetbook.UseCase(name: "Default", type: IncomingVerificationEmojiScreen, path: "$path/pages")
Widget incomingVerificationEmojiCompareScreen() => IncomingVerificationEmojiScreen(verificationHeaderType: VerificationHeaderType.compare);

class IncomingVerificationEmojiScreen extends StatefulWidget {
  final VerificationHeaderType verificationHeaderType;
  const IncomingVerificationEmojiScreen({super.key, required this.verificationHeaderType});

  @override
  State<IncomingVerificationEmojiScreen> createState() => IncomingVerificationEmojiScreenState();
}

class IncomingVerificationEmojiScreenState extends State<IncomingVerificationEmojiScreen> {
  final List<String> _emojis = [
    "assets/icons/pizza.png",
    "assets/icons/rocket.png",
    "assets/icons/book.png",
    "assets/icons/hammer.png",
    "assets/icons/pin.png",
    "assets/icons/map.png",
    "assets/icons/rocket.png",
    "assets/icons/book.png",
  ];

  @override
  Widget build(BuildContext context) {
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
                "Verification requested",
                style: consts.typography.text1.copyWith(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  return Image.asset(_emojis[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
