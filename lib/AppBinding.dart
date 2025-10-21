import 'package:get/get.dart';
import 'package:messenger/services/ChatService.dart';
import 'package:messenger/services/StorageService.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatService());
    Get.put(StorageService());
  }
}
