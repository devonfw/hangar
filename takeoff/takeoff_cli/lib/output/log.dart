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

  static void info(String message) {
    _logger.i("[INFO] $message");
  }

  static void debug(String message) {
    _logger.d("[DEBUG] $message");
  }

  static void error(String message) {
    _logger.e("[ERROR] $message");
  }

  static void warning(String message) {
    _logger.w("[WARNING] $message");
  }

  static void success(String message) {
    _logger.v("\x1B[32m[SUCCESS] $message");
  }
}
