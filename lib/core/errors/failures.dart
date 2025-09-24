import 'package:equatable/equatable.dart';

/// Base failure class for representing errors in the domain layer
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() {
    return 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Server-related failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Local storage failures
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
}

/// Firebase-related failures
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    super.code,
  });
}

/// WebSocket connection failures
class WebSocketFailure extends Failure {
  const WebSocketFailure({
    required super.message,
    super.code,
  });
}

/// File operation failures
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  final Duration? timeout;

  const TimeoutFailure({
    required super.message,
    super.code,
    this.timeout,
  });

  @override
  List<Object?> get props => [message, code, timeout];
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code,
  });
}