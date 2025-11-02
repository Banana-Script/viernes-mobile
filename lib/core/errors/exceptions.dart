/// Custom Exception Types for Viernes Mobile App
///
/// Provides a hierarchy of specific exceptions for better error handling
/// and debugging throughout the application.
library;

/// Base exception class for all custom exceptions
abstract class ViernesException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  final dynamic originalError;

  ViernesException(
    this.message, {
    this.stackTrace,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Network Exception
///
/// Thrown when network-related errors occur (HTTP errors, connectivity issues)
class NetworkException extends ViernesException {
  final int? statusCode;
  final String? endpoint;

  NetworkException(
    super.message, {
    this.statusCode,
    this.endpoint,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException: $message');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    if (endpoint != null) buffer.write(' [Endpoint: $endpoint]');
    return buffer.toString();
  }
}

/// Not Found Exception
///
/// Thrown when a requested resource is not found (HTTP 404)
class NotFoundException extends ViernesException {
  final String resourceType;
  final dynamic resourceId;

  NotFoundException(
    super.message, {
    this.resourceType = 'Resource',
    this.resourceId,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    return 'NotFoundException: $resourceType${resourceId != null ? " (ID: $resourceId)" : ""} not found - $message';
  }
}

/// Unauthorized Exception
///
/// Thrown when authentication fails or token is invalid (HTTP 401)
class UnauthorizedException extends ViernesException {
  final String? reason;

  UnauthorizedException(
    super.message, {
    this.reason,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('UnauthorizedException: $message');
    if (reason != null) buffer.write(' (Reason: $reason)');
    return buffer.toString();
  }
}

/// Forbidden Exception
///
/// Thrown when user doesn't have permission to access a resource (HTTP 403)
class ForbiddenException extends ViernesException {
  final String? resource;

  ForbiddenException(
    super.message, {
    this.resource,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ForbiddenException: $message');
    if (resource != null) buffer.write(' (Resource: $resource)');
    return buffer.toString();
  }
}

/// Validation Exception
///
/// Thrown when input validation fails
class ValidationException extends ViernesException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException(
    super.message, {
    this.fieldErrors,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ValidationException: $message');
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write('\nField Errors:');
      fieldErrors!.forEach((field, errors) {
        buffer.write('\n  - $field: ${errors.join(", ")}');
      });
    }
    return buffer.toString();
  }
}

/// Server Exception
///
/// Thrown when server returns an error (HTTP 500+)
class ServerException extends ViernesException {
  final int? statusCode;

  ServerException(
    super.message, {
    this.statusCode,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ServerException: $message');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    return buffer.toString();
  }
}

/// Cache Exception
///
/// Thrown when cache-related operations fail
class CacheException extends ViernesException {
  CacheException(
    super.message, {
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Parse Exception
///
/// Thrown when data parsing/deserialization fails
class ParseException extends ViernesException {
  final String? dataType;

  ParseException(
    super.message, {
    this.dataType,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ParseException: $message');
    if (dataType != null) buffer.write(' (Data Type: $dataType)');
    return buffer.toString();
  }
}

/// Timeout Exception
///
/// Thrown when an operation times out
class TimeoutException extends ViernesException {
  final Duration? timeout;

  TimeoutException(
    super.message, {
    this.timeout,
    super.stackTrace,
    super.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('TimeoutException: $message');
    if (timeout != null) buffer.write(' (Timeout: ${timeout!.inSeconds}s)');
    return buffer.toString();
  }
}
