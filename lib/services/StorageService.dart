import 'package:get/get.dart';

class StorageService extends GetxService {
  var enableCalls = false.obs;

  void clear() {
    enableCalls.value = false;
  }
}