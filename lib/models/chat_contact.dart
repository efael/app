class ChatContact {
  final int id;
  String? photo;
  final String firstName;
  final String lastName;
  final String lastMessage;
  final DateTime time;
  final String lastSeen;

  bool isOnline;
  final bool isGroup;
  bool isPinned;
  final bool isSecretChat;

  ChatContact({
    required this.id,
    this.photo,
    required this.firstName,
    required this.lastName,
    required this.lastMessage,
    required this.time,

    this.lastSeen = "last seen long time ago",
    this.isOnline = false,
    this.isGroup = false,
    this.isPinned = false,
    this.isSecretChat = false,
  });

  get fullName => "$firstName $lastName";

  get initials =>
      ("${('$firstName ')[0].toUpperCase()}${('$lastName ')[0].toUpperCase()}")
          .trim();

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    return ChatContact(
      id: json["id"],
      photo: json["photo"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      lastMessage: json["lastMessage"],

      //must be in ISO 8601 formats. eg: 2025-10-21 | 2025-10-21 14:30:00
      time: DateTime.parse(json["time"]),

      isGroup: json["isGroup"] ?? false,
      isPinned: json["isPinned"] ?? false,
      isSecretChat: json["isSecretChat"] ?? false,
      isOnline: json["isOnline"] ?? false,
    );
  }

  factory ChatContact.fromUserContactsJson(Map<String, dynamic> json) {
    return ChatContact(
      id: json["id"],
      photo: json["photo"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      isOnline: json["isOnline"] ?? false,

      lastMessage: "",
      time: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "photo": photo,
    "firstName": firstName,
    "lastName": lastName,
    "lastMessage": lastMessage,
    "time": time,

    "isGroup": isGroup,
    "isPinned": isPinned,
    "isSecretChat": isSecretChat,
  };
}
