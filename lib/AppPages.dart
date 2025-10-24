import 'package:get/get.dart';
import 'package:messenger/AppRoutes.dart';
import 'package:messenger/pages/chat/bindings/binding.dart';
import 'package:messenger/pages/chat/views/userDetailsPage.dart';
import 'package:messenger/pages/chat/views/view.dart';
import 'package:messenger/pages/home/bindings/binding.dart';
import 'package:messenger/pages/home/views/view.dart';
import 'package:messenger/pages/launcher/bindings/binding.dart';
import 'package:messenger/pages/launcher/views/view.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.BASE,
      page: () => const LauncherPage(),
      binding: LauncherBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.CHAT_DETAILS,
      page: () => const UserDetailsPage(),
      binding: ChatBinding(),
    ),
  ];
}
