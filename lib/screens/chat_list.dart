import 'package:flutter/material.dart';
import 'package:messenger/src/bindings/bindings.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    MatrixListChatsRequest(url: "").sendSignalToRust();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Text("chat-list")));
  }
}
