import '../controllers/controller.dart';
import 'package:get/get.dart';

class LauncherBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LauncherController());
  }
}
