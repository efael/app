import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:messenger/i18n/Messages.dart';
import 'package:messenger/pages/home/controllers/controller.dart';
import 'package:messenger/widgets/SettingsCardBlock.dart';
import 'package:messenger/widgets/UserAvatar.dart';

class SettingsView extends GetView<HomeController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Settings")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: UserAvatar(
                      userInitials: "AZ",
                      imagePath: "assets/tmp/user.png",
                      size: 100,
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Text(
                      "Azamat",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),

                  SettingsCardBlock(
                    children: [
                      SettingsInfoTile(
                        title: "+7 (911) 234-56-78",
                        subtitle: "Нажмите, чтобы изменить номер телефона",
                        onTap: () => {},
                      ),
                      SettingsInfoTile(
                        title: "@s_pokrovitel",
                        subtitle: "Имя пользователя",
                        onTap: () => {},
                      ),
                      SettingsInfoTile(
                        title: "Всё полезно, что на макет влезло.",
                        subtitle: "О себе",
                      ),
                    ],
                  ),

                  SettingsCardBlock(
                    children: [
                      SettingsInfoTile(
                        title: "Избранное",
                        icon: "assets/icons/bookmark.svg",
                      ),
                      SettingsInfoTile(
                        title: "Кошелёк",
                        icon: "assets/icons/bookmark.svg",
                      ),
                      SettingsInfoTile(
                        title: "Wallet",
                        icon: "assets/icons/face-smile.svg",
                      ),
                      SettingsInfoTile(
                        title: "Звонки и контакты",
                        icon: "assets/icons/phone.svg",
                      ),
                    ],
                  ),
                  SettingsCardBlock(
                    title: "settings".tr,
                    children: [
                      SettingsInfoTile(
                        title: "Настройки чатов",
                        icon: "assets/icons/message.svg",
                      ),
                      SettingsInfoTile(
                        title: "Конфиденциальность",
                        icon: "assets/icons/lock_2.svg",
                      ),
                      SettingsInfoTile(
                        title: "Уведомления и звуки",
                        icon: "assets/icons/bell.svg",
                      ),
                      SettingsInfoTile(
                        title: "Данные и память",
                        icon: "assets/icons/database.svg",
                      ),
                      SettingsInfoTile(
                        title: "Папки с чатами",
                        icon: "assets/icons/folder.svg",
                      ),
                      SettingsInfoTile(
                        title: "Устройства",
                        icon: "assets/icons/monitor.svg",
                      ),
                      SettingsInfoTile(
                        title: "language".tr,
                        icon: "assets/icons/globe.svg",
                        trailing: Text(Messages.activeLangLabel, style: TextStyle(fontSize: 14)),
                        onTap: () => {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.zero,
                                title: Text('select_lang'.tr),
                                content: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ...Messages.languages.map(
                                        (it) => ListTile(
                                          title: Text(it.label),
                                          onTap: () {
                                            Get.updateLocale(Locale(it.key));
                                            Navigator.of(dialogContext).pop();
                                          },
                                          contentPadding: EdgeInsets.symmetric(horizontal: 24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('cancel'.tr),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        },
                      ),
                      Obx(
                        () => SettingsInfoTile(
                          title: "calls".tr,
                          icon: "assets/icons/phone.svg",
                          onTap: () => {},
                          trailing: Transform.scale(
                            scale: 0.8,
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: controller.storageService.enableCalls.value,
                              onChanged: (state) =>
                                  controller.storageService.enableCalls.value = state,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SettingsCardBlock(
                    title: "Помощь",
                    children: [
                      SettingsInfoTile(
                        title: "Задать вопрос",
                        icon: "assets/icons/message-square.svg",
                      ),
                      SettingsInfoTile(
                        title: "Вопросы о Telegram",
                        icon: "assets/icons/alert-circle.svg",
                      ),
                      SettingsInfoTile(
                        title: "Политика конфиденциальности",
                        icon: "assets/icons/file-text.svg",
                      ),
                    ],
                  ),
                  SettingsCardBlock(
                    children: [
                      SettingsInfoTile(
                        title: "Выход",
                        trailing: SvgPicture.asset(
                          "assets/icons/log-out.svg",
                          colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                        ),
                        color: Colors.red,
                        onTap: () => showOkCancelAlertDialog(
                          context: context,
                          title: 'warning'.tr,
                          message: 'logoutText'.tr,
                          okLabel: "yes".tr,
                          cancelLabel: "no".tr,
                          defaultType: OkCancelAlertDefaultType.cancel,
                          onPopInvokedWithResult: (didPop, result) {
                            if (result == OkCancelResult.ok) {
                              controller.logout();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
