import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../l10n/app_localizations.dart';

/// Centralized error handling for authentication operations
/// Provides user-friendly error messages and consistent error handling
class AuthErrorHandler {
  /// Convert Firebase Auth exceptions to user-friendly messages
  static String getFirebaseAuthErrorMessage(
    FirebaseAuthException exception,
    AppLocalizations l10n,
  ) {
    switch (exception.code) {
      // Login errors
      case 'user-not-found':
        return l10n.userNotFound;
      case 'wrong-password':
        return l10n.invalidEmailOrPassword;
      case 'invalid-email':
        return l10n.invalidEmailFormat;
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return l10n.tooManyRequests;
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';

      // Registration errors
      case 'email-already-in-use':
        return l10n.emailAlreadyInUse;
      case 'weak-password':
        return l10n.weakPassword;
      case 'invalid-credential':
        return l10n.invalidEmailOrPassword;

      // Password reset errors
      case 'invalid-action-code':
        return 'The password reset link is invalid or has expired.';
      case 'expired-action-code':
        return 'The password reset link has expired. Please request a new one.';

      // Google Sign-In specific errors
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';

      // Network and general errors
      case 'network-request-failed':
        return l10n.networkError;
      case 'internal-error':
        return l10n.somethingWentWrong;
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      case 'invalid-api-key':
        return 'Invalid API key. Please contact support.';

      // Generic fallback
      default:
        return '${l10n.somethingWentWrong} (${exception.code})';
    }
  }

  /// Convert general exceptions to user-friendly messages
  static String getGeneralErrorMessage(
    Exception exception,
    AppLocalizations l10n,
  ) {
    if (exception is FirebaseAuthException) {
      return getFirebaseAuthErrorMessage(exception, l10n);
    }

    // Handle other common exceptions
    final message = exception.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return l10n.networkError;
    }

    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (message.contains('format')) {
      return l10n.invalidEmailFormat;
    }

    // Generic fallback
    return l10n.somethingWentWrong;
  }

  /// Handle Google Sign-In specific errors
  static String getGoogleSignInErrorMessage(
    String errorCode,
    AppLocalizations l10n,
  ) {
    switch (errorCode) {
      case 'sign_in_canceled':
        return l10n.googleSignInCancelled;
      case 'sign_in_failed':
        return l10n.googleSignInFailed;
      case 'network_error':
        return l10n.networkError;
      case 'sign_in_required':
        return 'Please sign in to continue.';
      default:
        return l10n.googleSignInFailed;
    }
  }

  /// Check if error is retryable
  static bool isRetryableError(String errorCode) {
    const retryableErrors = [
      'network-request-failed',
      'timeout',
      'internal-error',
      'too-many-requests',
    ];

    return retryableErrors.contains(errorCode);
  }

  /// Check if error requires user action
  static bool requiresUserAction(String errorCode) {
    const userActionErrors = [
      'weak-password',
      'invalid-email',
      'email-already-in-use',
      'wrong-password',
      'user-not-found',
      'invalid-credential',
    ];

    return userActionErrors.contains(errorCode);
  }

  /// Get suggestion for error resolution
  static String? getErrorSuggestion(String errorCode, AppLocalizations l10n) {
    switch (errorCode) {
      case 'weak-password':
        return 'Try using a stronger password with at least 8 characters, including uppercase, lowercase, and numbers.';
      case 'invalid-email':
        return 'Please check your email address format.';
      case 'email-already-in-use':
        return 'Try signing in instead, or use the "Forgot Password" option if you don\'t remember your password.';
      case 'user-not-found':
        return 'Please check your email address or create a new account.';
      case 'wrong-password':
        return 'Please check your password or use the "Forgot Password" option.';
      case 'too-many-requests':
        return 'Please wait a few minutes before trying again.';
      case 'network-request-failed':
        return 'Please check your internet connection and try again.';
      default:
        return null;
    }
  }

  /// Log error for debugging (in development only)
  static void logError(Exception exception, String context) {
    // Only log in development mode
    assert(() {
      dev.log('Auth Error in $context: $exception', name: 'AuthErrorHandler');
      if (exception is FirebaseAuthException) {
        dev.log('Firebase Auth Error Code: ${exception.code}', name: 'AuthErrorHandler');
        dev.log('Firebase Auth Error Message: ${exception.message}', name: 'AuthErrorHandler');
      }
      return true;
    }());
  }

  /// Create error details for reporting
  static Map<String, dynamic> createErrorReport(
    Exception exception,
    String context,
  ) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'context': context,
      'exception_type': exception.runtimeType.toString(),
      'exception_message': exception.toString(),
      if (exception is FirebaseAuthException) ...{
        'firebase_code': exception.code,
        'firebase_message': exception.message,
        'is_retryable': isRetryableError(exception.code),
        'requires_user_action': requiresUserAction(exception.code),
      },
    };
  }
}