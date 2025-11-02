import 'package:get/get.dart';
import 'package:messenger/config.dart';
import 'package:messenger/rinf/bindings/bindings.dart';
import 'package:messenger/routes.dart';
import 'package:messenger/services/chat_service.dart';
import 'package:path_provider/path_provider.dart';

import '../../base_controller.dart';

class LauncherController extends BaseController {
  Future<void> initRust() async {
    final chatService = Get.find<ChatService>();
    final applicationSupportDirectory = await getApplicationSupportDirectory();

    MatrixInitRequest(
      homeserverUrl: AppConfig.homeserver,
      applicationSupportDirectory: applicationSupportDirectory.path,
    ).sendSignalToRust();

    final response = await MatrixInitResponse.rustSignalStream.first;

    switch (response.message) {
      case MatrixInitResponseLoggedIn(value: final userId):
        chatService.currentUserId.value = userId;
        Get.offAndToNamed(AppRoutes.home);
      case MatrixInitResponseNotLoggedIn():
        Get.offAndToNamed(AppRoutes.auth);
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
