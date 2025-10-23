import 'package:get/get.dart';
import 'package:messenger/models/CallHistory.dart';
import 'package:messenger/models/ChatContact.dart';

class ChatService extends GetxService {
  var chatContacts = <ChatContact>[].obs;
  var activeChat = Rx<ChatContact?>(null);
  var unreadMessages = <int, int>{}.obs;

  var userContacts = <ChatContact>[].obs;
  var callHistory = <CallHistory>[].obs;

  void clear() {
    activeChat.value = null;

    chatContacts.clear();
    userContacts.clear();
    callHistory.clear();
    unreadMessages.clear();
  }
}