import 'package:get/get.dart';

import '../controllers/controller.dart';

class LauncherBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LauncherController());
  }
}
