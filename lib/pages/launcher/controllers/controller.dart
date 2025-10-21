import 'package:messenger/AppRoutes.dart';

import '../../BaseController.dart';
import 'package:get/get.dart';

class LauncherController extends BaseController {
  @override
  void onReady() {
    super.onReady();

    Get.offAndToNamed(AppRoutes.HOME);
  }
}
