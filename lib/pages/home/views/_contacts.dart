import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:messenger/pages/home/controllers/controller.dart';
import 'package:messenger/widgets/user_avatar.dart';

class ContactsListView extends GetView<HomeController> {
  const ContactsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("contacts".tr)),
      body: Obx(
        () => (controller.chatService.userContacts.isNotEmpty)
            ? ListView.separated(
                controller: controller.pageScrollController["contacts"],
                padding: EdgeInsets.zero,
                itemCount: controller.chatService.userContacts.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    color: Color(0x55314356),
                    height: 1,
                    thickness: 1,
                  );
                },
                itemBuilder: (context, i) {
                  var item = controller.chatService.userContacts[i];

                  return Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(splashColor: Colors.transparent),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      onTap: () => controller.openChat(item),
                      title: Text(
                        item.fullName,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      leading: UserAvatar(
                        imagePath: item.photo,
                        userInitials: item.initials,
                        size: 42,
                      ),
                      trailing: Obx(() {
                        var msgCount =
                            (controller.chatService.unreadMessages.containsKey(
                              item.id,
                            ))
                            ? controller.chatService.unreadMessages[item.id]!
                            : 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            (msgCount > 0)
                                ? Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                      maxWidth: 24,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Center(
                                      child: Text(
                                        msgCount.toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        );
                      }),
                    ),
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/users.svg",
                      width: 128,
                      height: 128,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text("empty".tr, style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
      ),
    );
  }
}
