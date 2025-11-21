import 'dart:developer' as developer;

class AppLogger {
  static void d(String tag, Object? message) {
    developer.log(message?.toString() ?? '', name: tag);
  }

  static void e(String tag, Object? message) {
    developer.log(message?.toString() ?? '', name: tag, level: 1000);
  }
}
