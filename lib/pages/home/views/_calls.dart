import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:messenger/enums/CallStatus.dart';
import 'package:messenger/pages/home/controllers/controller.dart';
import 'package:messenger/widgets/UserAvatar.dart';

class CallsListView extends GetView<HomeController> {
  const CallsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calls")),
      body: Obx(
        () => (controller.chatService.callHistory.isNotEmpty)
            ? ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: controller.chatService.callHistory.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(color: Color(0x55314356), height: 1, thickness: 1);
                },
                itemBuilder: (context, i) {
                  var item = controller.chatService.callHistory[i];

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    onTap: () => {},
                    title: Text(
                      item.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: (item.status == CallStatus.missed) ? Colors.red : Colors.white,
                      ),
                    ),
                    subtitle: Text(item.status.label.tr),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          (item.status == CallStatus.outgoing) ? Icons.call_made : Icons.call_received,
                          color: (item.status == CallStatus.missed) ? Colors.red : null,
                        ),
                        SizedBox(width: 15),
                        UserAvatar(imagePath: item.photo, userInitials: item.initials, size: 42),
                      ],
                    ),
                  );
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/phone.svg",
                      width: 128,
                      height: 128,
                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    Text("empty".tr, style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),
      ),
    );
  }
}
