import 'dart:developer' as developer;

import '../config/environment_config.dart';

class AppLogger {
  static const String _prefix = '[Viernes]';

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (EnvironmentConfig.enableVerboseLogging) {
      developer.log(
        message,
        name: tag != null ? '$_prefix $tag' : _prefix,
        level: 500,
        error: error,
        stackTrace: stackTrace,
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

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag != null ? '$_prefix $tag' : _prefix,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag != null ? '$_prefix $tag' : _prefix,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log API request details
  static void apiRequest(String method, String endpoint, {Map<String, dynamic>? params}) {
    if (EnvironmentConfig.enableVerboseLogging) {
      final buffer = StringBuffer('API Request: $method $endpoint');
      if (params != null && params.isNotEmpty) {
        buffer.write('\nParams: $params');
      }
      debug(buffer.toString(), tag: 'API');
    }
  }

  /// Log API response details
  static void apiResponse(int statusCode, String endpoint, {dynamic data}) {
    if (EnvironmentConfig.enableVerboseLogging) {
      final buffer = StringBuffer('API Response: $statusCode $endpoint');
      if (data != null) {
        buffer.write('\nData: $data');
      }
      debug(buffer.toString(), tag: 'API');
    }
  }

  /// Log API error details
  static void apiError(String endpoint, Object error, StackTrace stackTrace, {int? statusCode}) {
    final buffer = StringBuffer('API Error: $endpoint');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    AppLogger.error(buffer.toString(), tag: 'API', error: error, stackTrace: stackTrace);
  }
}
