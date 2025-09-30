import 'package:flutter/material.dart';
import 'package:messenger/constants.dart';
import 'package:messenger/widgets/chat_header.dart';
import 'package:messenger/widgets/message_box.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: consts.colors.dominant.bgMediumContrast,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: SafeArea(child: ChatHeader()),
      ),
      body: SafeArea(
        left: false,
        right: false,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: Container(
                    width: double.infinity,
                    color: consts.colors.dominant.bgHighContrast,
                    child: Text("content"),
                  ),
                ),
              ),
              SafeArea(child: MessageBox()),
            ],
          ),
        ),
      ),
    );
  }
}
