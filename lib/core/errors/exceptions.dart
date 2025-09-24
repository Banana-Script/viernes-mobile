/// Base exception class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Server-related exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalException,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// API-related exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({
    required super.message,
    super.code,
    super.originalException,
    this.statusCode,
  });
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Local storage exceptions
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    super.originalException,
    this.fieldErrors,
  });
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Firebase-related exceptions
class FirebaseException extends AppException {
  const FirebaseException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// WebSocket-related exceptions
class WebSocketException extends AppException {
  const WebSocketException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// File operation exceptions
class FileException extends AppException {
  const FileException({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// Timeout exceptions
class TimeoutException extends AppException {
  final Duration? timeout;

  const TimeoutException({
    required super.message,
    super.code,
    super.originalException,
    this.timeout,
  });
}

/// Biometric authentication exceptions
class BiometricException extends AppException {
  const BiometricException({
    required super.message,
    super.code,
    super.originalException,
  });
}