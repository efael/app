import 'package:intl/intl.dart';

final DateFormat shortDateTimeFormatter = DateFormat(DateFormat.ABBR_MONTH_DAY);
final DateFormat hourMinuteFormatter = DateFormat(DateFormat.HOUR24_MINUTE);

String formatDateTime(DateTime target) {
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
