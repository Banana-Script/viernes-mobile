import 'dart:developer' as developer;
import '../config/environment_config.dart';

class AppLogger {
  static const String _prefix = '[Viernes]';

  static void debug(String message, {String? tag, Object? error}) {
    if (EnvironmentConfig.enableVerboseLogging) {
      developer.log(
        message,
        name: tag != null ? '$_prefix $tag' : _prefix,
        level: 500,
        error: error,
      );
    }
  }

  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag != null ? '$_prefix $tag' : _prefix,
      level: 800,
    );
  }

  static void warning(String message, {String? tag, Object? error}) {
    developer.log(
      message,
      name: tag != null ? '$_prefix $tag' : _prefix,
      level: 900,
      error: error,
    );
  }

  static void error(String message, {String? tag, Object? error}) {
    developer.log(
      message,
      name: tag != null ? '$_prefix $tag' : _prefix,
      level: 1000,
      error: error,
    );
  }
}