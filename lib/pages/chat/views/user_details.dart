import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messenger/pages/chat/controllers/controller.dart';
import 'package:messenger/widgets/user_avatar.dart';

class UserDetailsPage extends GetView<ChatController> {
  const UserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: 60),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: "userImage",
                    child: UserAvatar(
                      userInitials:
                          controller.chatService.activeChat.value?.initials,
                      imagePath: controller.chatService.activeChat.value?.photo,
                      size: 100,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Hero(
                    tag: "userName",
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        controller.chatService.activeChat.value?.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Hero(
                    tag: "userStatus",
                    child: Material(
                      type: MaterialType.transparency,
                      child: Text(
                        controller.chatService.activeChat.value?.lastSeen ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
