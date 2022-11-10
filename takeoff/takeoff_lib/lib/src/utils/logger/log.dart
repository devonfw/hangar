import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
      level: Level.verbose,
      filter: ProductionFilter(),
      printer: PrettyPrinter(
          methodCount: 0,
          noBoxingByDefault: true,
          colors: true,
          printEmojis: false),
      output: null);

  static void info(String message, {showTimestamp = true}) {
    String badge = (showTimestamp) ? "[INFO ${DateTime.now()}]" : "[INFO]";
    _logger.i("$badge $message");
  }

  static void debug(String message, {showTimestamp = true}) {
    String badge = (showTimestamp) ? "[DEBUG ${DateTime.now()}]" : "[DEBUG]";
    _logger.d("$badge $message");
  }

  static void error(String message, {showTimestamp = true}) {
    String badge = (showTimestamp) ? "[ERROR ${DateTime.now()}]" : "[ERROR]";
    _logger.e("$badge $message");
  }

  static void warning(String message, {showTimestamp = true}) {
    String badge =
        (showTimestamp) ? "[WARNING ${DateTime.now()}]" : "[WARNING]";
    _logger.w("$badge $message");
  }

  static void success(String message, {showTimestamp = true}) {
    String badge =
        (showTimestamp) ? "[SUCCESS ${DateTime.now()}]" : "[SUCCESS]";
    _logger.v("\x1B[32m$badge $message");
  }
}
