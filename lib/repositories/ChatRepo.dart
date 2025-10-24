import 'package:messenger/enums/CallStatus.dart';
import 'package:messenger/models/CallHistory.dart';
import 'package:messenger/models/ChatContact.dart';

class ChatRepo {
  Future<List<ChatContact>> loadChatContacts() async {
    return [
      ChatContact(
        id: 1,
        photo: "assets/tmp/user0.png",
        firstName: "Ilya",
        lastName: "",
        lastMessage: "Текст сообщения для карточки чата с анонсом",
        time: DateTime.now(),
      ),
      ChatContact(
        id: 2,
        photo: "assets/tmp/user1.png",
        firstName: "Ar",
        lastName: "",
        lastMessage: "Текст сообщения для карточки чата с анонсом",
        time: DateTime(2025, 10, 21, 15, 27),
      ),
      ChatContact(
        id: 3,
        photo: "assets/tmp/user2.png",
        firstName: "Моя муза",
        lastName: "",
        lastMessage: "Вы сделали скриншот!",
        time: DateTime(2025, 10, 20, 10, 0),
        isSecretChat: true,
        isOnline: true,
      ),
      ChatContact(
        id: 4,
        photo: "assets/tmp/user3.png",
        firstName: "Danial",
        lastName: "Siddiki",
        lastMessage: "Текст сообщения для карточки чата с анонсом.",
        time: DateTime(2025, 10, 18, 10, 0),
        isOnline: true,
      ),
      ChatContact(
        id: 5,
        photo: "assets/tmp/user4.png",
        firstName: "Mikhail",
        lastName: "Naer",
        lastMessage:
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        time: DateTime(2025, 10, 9, 10, 0),
      ),
      ChatContact(
        id: 6,
        photo: "assets/tmp/user5.png",
        firstName: "Mihail",
        lastName: "Guryev",
        lastMessage: "Голосовое сообщение",
        time: DateTime(2025, 10, 9, 10, 0),
      ),
      ChatContact(
        id: 7,
        photo: "assets/tmp/user6.png",
        firstName: "Alexander",
        lastName: "Zimin",
        lastMessage: "Текст сообщения для карточки чата с анонсом.",
        time: DateTime(2025, 10, 9, 10, 0),
      ),
      ChatContact(
        id: 8,
        firstName: "Kirill",
        lastName: "Karmanov",
        lastMessage: "Текст сообщения для карточки чата с анонсом.",
        time: DateTime(2025, 10, 9, 10, 0),
      ),
      ChatContact(
        id: 9,
        photo: "assets/tmp/user7.png",
        firstName: "Illia",
        lastName: "Pyshniak",
        lastMessage: "Текст сообщения для карточки чата с анонсом.",
        time: DateTime(2025, 10, 9, 10, 0),
      ),
      ChatContact(
        id: 10,
        photo: "assets/tmp/user8.png",
        firstName: "Edward",
        lastName: "B.",
        lastMessage: "Текст сообщения для карточки чата с анонсом.",
        time: DateTime(2025, 10, 9, 10, 0),
      ),
      ChatContact(
        id: 11,
        photo: "assets/tmp/user9.png",
        firstName: "Daniel",
        lastName: "Menakhovsky",
        lastMessage: "Текст сообщения для карточки чата с анонсом",
        time: DateTime(2025, 10, 9, 10, 0),
      ),
    ];
  }

  Future<List<ChatContact>> loadUserContacts() async {
    var apiData = [
      {"id": 1, "photo": "assets/tmp/user0.png", "firstName": "Ilya", "lastName": ""},
      {"id": 2, "photo": "assets/tmp/user1.png", "firstName": "Ar", "lastName": ""},
      {"id": 3, "photo": "assets/tmp/user2.png", "firstName": "Моя", "lastName": "муза"},
      {"id": 4, "photo": "assets/tmp/user3.png", "firstName": "Danial", "lastName": "Siddiki"},
      {"id": 5, "photo": "assets/tmp/user4.png", "firstName": "Mikhail", "lastName": "Naer"},
      {"id": 6, "firstName": "Mihail", "lastName": "Guryev"},
      {"id": 7, "photo": "assets/tmp/user6.png", "firstName": "Alexander", "lastName": "Zimin"},
      {"id": 8, "photo": "assets/tmp/user7.png", "firstName": "Kirill", "lastName": "Karmanov"},
      {"id": 9, "photo": "assets/tmp/user8.png", "firstName": "Illia", "lastName": "Pyshniak"},
      {"id": 10, "photo": "assets/tmp/user9.png", "firstName": "Edward", "lastName": "B."},
      {"id": 11, "photo": "assets/tmp/user0.png", "firstName": "Daniel", "lastName": "Menakhovsky", "isOnline": true},
    ];

    return apiData.map((it) => ChatContact.fromUserContactsJson(it)).toList();
  }

  Future<List<CallHistory>> loadCallsHistory() async {
    return [
      CallHistory(
        userId: 1,
        photo: "assets/tmp/user0.png",
        firstName: "Ilya",
        lastName: "",
        time: DateTime(2025, 10, 9, 10, 0),
        status: CallStatus.missed,
      ),
      CallHistory(
        userId: 3,
        photo: "assets/tmp/user2.png",
        firstName: "Моя",
        lastName: "муза",
        time: DateTime(2025, 10, 9, 10, 0),
        status: CallStatus.incoming,
      ),
      CallHistory(
        userId: 6,
        firstName: "Mihail",
        lastName: "Guryev",
        time: DateTime(2025, 10, 9, 10, 0),
        status: CallStatus.outgoing,
      ),
      CallHistory(
        userId: 8,
        photo: "assets/tmp/user7.png",
        firstName: "Kirill",
        lastName: "Karmanov",
        time: DateTime(2025, 10, 9, 10, 0),
        status: CallStatus.missed,
      ),
    ];
  }
}
