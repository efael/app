import 'package:intl/intl.dart';
import 'package:messenger/src/bindings/signals/signals.dart';

final DateFormat shortDateTimeFormatter = DateFormat(DateFormat.ABBR_MONTH_DAY);
final DateFormat hourMinuteFormatter = DateFormat(DateFormat.HOUR24_MINUTE);

String formatTimestamp(Timestamp timestamp) {
  final target = DateTime.fromMillisecondsSinceEpoch(timestamp.value.toInt());
  final now = DateTime.now();

  // print("now ${now.day} ${now.month} ${now.year}");
  // print("target ${target.day} ${target.month} ${target.year}");

  if (now.day != target.day ||
      now.month != target.month ||
      now.year != target.year) {
    return shortDateTimeFormatter.format(target);
  }
  return hourMinuteFormatter.format(target);
}
