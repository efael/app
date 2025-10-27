enum CallStatus { incoming, outgoing, missed }

CallStatus phoneCallStatusFromString(String value) {
  return CallStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => CallStatus.missed,
  );
}

extension Extentions on CallStatus {
  String get label {
    switch (this) {
      case CallStatus.incoming:
        return "incoming";
      case CallStatus.outgoing:
        return "outgoing";
      case CallStatus.missed:
        return "missed";
    }
  }
}
