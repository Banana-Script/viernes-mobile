import '../../../../core/errors/failures.dart';

class AuthErrorHandler {
  /// Convert failures to user-friendly error messages
  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure:
        return _getAuthErrorMessage(failure);
      case NetworkFailure:
        return _getNetworkErrorMessage(failure);
      case ServerFailure:
        return _getServerErrorMessage(failure as ServerFailure);
      case ValidationFailure:
        return _getValidationErrorMessage(failure as ValidationFailure);
      case StorageFailure:
        return _getStorageErrorMessage(failure);
      case PermissionFailure:
        return _getPermissionErrorMessage(failure);
      case FirebaseFailure:
        return _getFirebaseErrorMessage(failure);
      case TimeoutFailure:
        return _getTimeoutErrorMessage(failure);
      default:
        return failure.message.isNotEmpty ? failure.message : 'An unexpected error occurred';
    }
  }

  static String _getAuthErrorMessage(Failure failure) {
    final message = failure.message.toLowerCase();

    // Firebase Auth specific errors
    if (message.contains('user-not-found')) {
      return 'No account found with this email address';
    }
    if (message.contains('wrong-password') || message.contains('invalid-credential')) {
      return 'Invalid email or password';
    }
    if (message.contains('invalid-email')) {
      return 'Please enter a valid email address';
    }
    if (message.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support';
    }
    if (message.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later';
    }
    if (message.contains('operation-not-allowed')) {
      return 'This sign-in method is not enabled';
    }
    if (message.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password';
    }
    if (message.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    }
    if (message.contains('requires-recent-login')) {
      return 'Please sign in again to continue';
    }
    if (message.contains('network-request-failed')) {
      return 'Network error. Please check your connection';
    }
    if (message.contains('cancelled') || message.contains('canceled')) {
      return 'Sign in was cancelled';
    }

    return failure.message.isNotEmpty ? failure.message : 'Authentication failed';
  }

  static String _getNetworkErrorMessage(Failure failure) {
    return 'No internet connection. Please check your network and try again';
  }

  static String _getServerErrorMessage(ServerFailure failure) {
    final statusCode = failure.statusCode;

    switch (statusCode) {
      case 400:
        return failure.message.isNotEmpty ? failure.message : 'Invalid request';
      case 401:
        return 'Your session has expired. Please sign in again';
      case 403:
        return 'You don\'t have permission to perform this action';
      case 404:
        return 'Service not found. Please try again later';
      case 422:
        return failure.message.isNotEmpty ? failure.message : 'Validation failed';
      case 429:
        return 'Too many requests. Please wait a moment and try again';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later';
      default:
        return failure.message.isNotEmpty ? failure.message : 'Request failed';
    }
  }

  static String _getValidationErrorMessage(ValidationFailure failure) {
    if (failure.fieldErrors != null && failure.fieldErrors!.isNotEmpty) {
      // Return the first field error
      final firstField = failure.fieldErrors!.keys.first;
      final firstErrors = failure.fieldErrors![firstField]!;
      if (firstErrors.isNotEmpty) {
        return firstErrors.first;
      }
    }

    return failure.message.isNotEmpty ? failure.message : 'Please check your input';
  }

  static String _getStorageErrorMessage(Failure failure) {
    return 'Failed to save data locally. Please try again';
  }

  static String _getPermissionErrorMessage(Failure failure) {
    final message = failure.message.toLowerCase();

    if (message.contains('biometric')) {
      return 'Biometric authentication is not available or not set up';
    }
    if (message.contains('camera')) {
      return 'Camera permission is required';
    }
    if (message.contains('photo') || message.contains('gallery')) {
      return 'Photo library permission is required';
    }

    return failure.message.isNotEmpty ? failure.message : 'Permission denied';
  }

  static String _getFirebaseErrorMessage(Failure failure) {
    return failure.message.isNotEmpty ? failure.message : 'Firebase service error';
  }

  static String _getTimeoutErrorMessage(Failure failure) {
    return 'Request timed out. Please check your connection and try again';
  }

  /// Get a user-friendly error message for common scenarios
  static String getGenericErrorMessage(String operation) {
    switch (operation.toLowerCase()) {
      case 'login':
      case 'signin':
        return 'Failed to sign in. Please check your credentials and try again';
      case 'logout':
      case 'signout':
        return 'Failed to sign out. Please try again';
      case 'register':
      case 'signup':
        return 'Failed to create account. Please try again';
      case 'reset':
      case 'forgot':
        return 'Failed to send password reset email. Please try again';
      case 'google':
        return 'Google sign in failed. Please try again';
      case 'biometric':
        return 'Biometric authentication failed. Please try again';
      default:
        return 'Something went wrong. Please try again';
    }
  }

  /// Check if error is retryable
  static bool isRetryableError(Failure failure) {
    if (failure is NetworkFailure) return true;
    if (failure is TimeoutFailure) return true;

    if (failure is ServerFailure) {
      final statusCode = failure.statusCode;
      return statusCode == 429 || // Too many requests
          statusCode == 500 || // Internal server error
          statusCode == 502 || // Bad gateway
          statusCode == 503; // Service unavailable
    }

    final message = failure.message.toLowerCase();
    return message.contains('network') ||
        message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('server') ||
        message.contains('try again');
  }

  /// Check if error requires re-authentication
  static bool requiresReauth(Failure failure) {
    if (failure is ServerFailure && failure.statusCode == 401) {
      return true;
    }

    final message = failure.message.toLowerCase();
    return message.contains('expired') ||
        message.contains('unauthorized') ||
        message.contains('invalid token') ||
        message.contains('requires-recent-login');
  }

  /// Get error type for analytics or logging
  static String getErrorType(Failure failure) {
    return failure.runtimeType.toString().replaceAll('Failure', '').toLowerCase();
  }

  /// Check if error should be reported to crash analytics
  static bool shouldReport(Failure failure) {
    // Don't report user-caused errors
    if (failure is ValidationFailure) return false;
    if (failure is AuthFailure) {
      final message = failure.message.toLowerCase();
      return !message.contains('cancelled') &&
          !message.contains('invalid-email') &&
          !message.contains('wrong-password') &&
          !message.contains('user-not-found');
    }

    return true;
  }
}