import 'dart:math';

class GeneralHelper {
  static const String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  static String getRandomString(int length) {
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => _chars.codeUnitAt(GeneralHelper._rnd.nextInt(_chars.length)),
      ),
    );
  }
}
