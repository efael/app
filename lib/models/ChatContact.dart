class ChatContact {
  final int id;
  final String? photo;
  final String firstName;
  final String lastName;
  final String lastMessage;
  final DateTime time;

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

    this.isOnline = false,
    this.isGroup = false,
    this.isPinned = false,
    this.isSecretChat = false,
  });

  get fullName => "${this.firstName} ${this.lastName}";

  get initials =>
      "${(this.firstName + ' ')[0].toUpperCase()}${(this.lastMessage + ' ')[0].toUpperCase()}";

  ChatContact fromJson(Map<String, dynamic> json) {
    return ChatContact(
      id: json["id"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      lastMessage: json["lastMessage"],

      //must be in ISO 8601 formats. eg: 2025-10-21 | 2025-10-21 14:30:00
      time: DateTime.parse(json["time"]),

      isGroup: json["isGroup"],
      isPinned: json["isPinned"],
      isSecretChat: json["isSecretChat"],
    );
  }

  Map<String, dynamic> toStoreJson() => {
    "photo": this.photo,
    "firstName": this.firstName,
    "lastName": this.lastName,
    "lastMessage": this.lastMessage,
    "time": this.time,

    "isGroup": this.isGroup,
    "isPinned": this.isPinned,
    "isSecretChat": this.isSecretChat,
  };
}
