import 'package:get/get.dart';
import 'package:messenger/models/ChatContact.dart';

class ChatService extends GetxService {
  var chatContacts = <ChatContact>[].obs;
  var activeChat = Rx<ChatContact?>(null);
  var unreadMessages = <int, int>{}.obs;
}