import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:messenger/widgets/svg_image.dart';

class ChatMessageBar extends StatefulWidget {
  final Function(MatrixSendMessageContent) onSendMessage;

  const ChatMessageBar({super.key, required this.onSendMessage});

  @override
  State<ChatMessageBar> createState() => _ChatMessageBarState();
}

class _ChatMessageBarState extends State<ChatMessageBar> {
  final TextEditingController textController = TextEditingController();
  bool isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    textController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final bool textIsEmpty = textController.text.isEmpty;
    if (isInputEmpty != textIsEmpty) {
      setState(() {
        isInputEmpty = textIsEmpty;
      });
    }
  }

  void sendMessage() {
    widget.onSendMessage(
      MatrixSendMessageContentMessage(body: textController.text),
    );
    textController.clear();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 3000),
      // height: 150,
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      color: Color(0xFF212F3F),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // IconButton(
          //   onPressed: () => {},
          //   icon: SvgPicture.asset(
          //     "assets/icons/face-smile.svg",
          //     colorFilter: ColorFilter.mode(Color(0xFF6C808C), BlendMode.srcIn),
          //   ),
          // ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 7,
              controller: textController,
              decoration: InputDecoration(
                hintText: 'message'.tr,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
              ),
            ),
          ),
          // IconButton(
          //   onPressed: () => {},
          //   icon: SvgPicture.asset(
          //     "assets/icons/face-smile.svg",
          //     colorFilter: ColorFilter.mode(Color(0xFF6C808C), BlendMode.srcIn),
          //   ),
          // ),
          InkWell(
            onTap: (isInputEmpty) ? null : sendMessage,
            child: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: (isInputEmpty) ? Colors.transparent : Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgImage(
                  "assets/icons/arrow-up.svg",
                  color: (isInputEmpty) ? Color(0xFF6C808C) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
