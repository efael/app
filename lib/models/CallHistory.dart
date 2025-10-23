import 'package:messenger/enums/CallStatus.dart';

class CallHistory {
  final int userId;
  final String? photo;
  final String firstName;
  final String lastName;
  final DateTime time;
  final CallStatus status;

  CallHistory({
    required this.userId,
    this.photo,
    required this.firstName,
    required this.lastName,
    required this.time,
    required this.status,
  });

  get fullName => "$firstName $lastName";

  get initials => ("${(firstName + ' ')[0].toUpperCase()}${(lastName + ' ')[0].toUpperCase()}").trim();

  factory CallHistory.fromJson(Map<String, dynamic> json) {
    return CallHistory(
      userId: json["userId"],
      photo: json["photo"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      time: DateTime.parse(json["time"]),
      status: phoneCallStatusFromString(json["status"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "photo": photo,
    "firstName": firstName,
    "lastName": lastName,
    "time": time,
    "status": status,
  };
}
