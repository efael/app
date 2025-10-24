import 'package:messenger/AppConfig.dart';
import 'package:messenger/AppRoutes.dart';
import 'package:messenger/src/bindings/bindings.dart';
import 'package:path_provider/path_provider.dart';

import '../../BaseController.dart';
import 'package:get/get.dart';

class LauncherController extends BaseController {
  Future<void> initRust() async {
    final applicationSupportDirectory = await getApplicationSupportDirectory();

    MatrixInitRequest(
      homeserverUrl: AppConfig.homeserver,
      applicationSupportDirectory: applicationSupportDirectory.path,
    ).sendSignalToRust();

    final response = await MatrixInitResponse.rustSignalStream.first;

    switch (response.message) {
      case MatrixInitResponseOk(isLoggedIn: final isLoggedIn):
        if (isLoggedIn) {
          Get.offAndToNamed(AppRoutes.home);
        } else {
          Get.offAndToNamed(AppRoutes.auth);
        }

      case MatrixInitResponseErr(message: final message):
        // TODO: graceful handling of it. retry button
        print(message);
    }
  }

  @override
  void onReady() {
    super.onReady();

    initRust();
  }
}
