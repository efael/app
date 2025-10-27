import 'package:get/get.dart';
import 'package:messenger/services/chat_service.dart';
import 'package:messenger/services/storage_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatService());
    Get.put(StorageService());
  }
}
