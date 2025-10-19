import 'package:get/get.dart';
import 'package:messenger/AppRoutes.dart';
import 'package:messenger/pages/launcher/bindings/binding.dart';
import 'package:messenger/pages/launcher/views/view.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.BASE,
      page: () => const LauncherPage(),
      binding: LauncherBinding(),
    ),
  ];
}
