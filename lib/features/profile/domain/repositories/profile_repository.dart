import 'dart:io';
import '../entities/user_profile.dart';
import '../entities/app_info.dart';
import '../../../../core/errors/failures.dart';

/// Abstract repository for profile-related operations
/// Defines the contract for data operations that can be implemented by different data sources
abstract class ProfileRepository {
  // === USER PROFILE OPERATIONS ===

  /// Get the current user profile from Firebase and backend
  Future<Either<Failure, UserProfile>> getCurrentUserProfile();

  /// Update user profile information
  Future<Either<Failure, UserProfile>> updateUserProfile(UserProfile profile);

  /// Update user avatar/photo
  Future<Either<Failure, String>> updateUserAvatar(File imageFile);

  /// Delete user avatar
  Future<Either<Failure, void>> deleteUserAvatar();

  // === USER AVAILABILITY OPERATIONS ===

  /// Get current user availability status
  Future<Either<Failure, bool>> getUserAvailabilityStatus();

  /// Toggle user availability status
  Future<Either<Failure, bool>> toggleUserAvailability(bool isAvailable);

  // === USER PREFERENCES OPERATIONS ===

  /// Get user preferences from local storage
  Future<Either<Failure, UserPreferences>> getUserPreferences();

  /// Save user preferences to local storage
  Future<Either<Failure, void>> saveUserPreferences(UserPreferences preferences);

  // === ACCOUNT MANAGEMENT OPERATIONS ===

  /// Request password reset
  Future<Either<Failure, void>> requestPasswordReset(String email);

  /// Change user password
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);

  /// Delete user account (soft delete)
  Future<Either<Failure, void>> deleteAccount(String password);

  /// Request data export
  Future<Either<Failure, void>> requestDataExport();

  // === APP INFORMATION OPERATIONS ===

  /// Get application information
  Future<Either<Failure, AppInfo>> getAppInfo();

  /// Check for app updates
  Future<Either<Failure, bool>> checkForUpdates();

  // === AUTHENTICATION OPERATIONS ===

  /// Sign out user from all sessions
  Future<Either<Failure, void>> signOut();

  /// Refresh authentication token
  Future<Either<Failure, void>> refreshAuthToken();
}

/// Extension for Either type to handle success/failure cases
/// This provides a clean way to handle repository responses
extension EitherExtension<L, R> on Future<Either<L, R>> {
  /// Execute a function when the result is successful
  Future<Either<L, T>> then<T>(Future<Either<L, T>> Function(R) onSuccess) async {
    final result = await this;
    return result.fold(
      (failure) => Left(failure),
      (success) => onSuccess(success),
    );
  }

  /// Execute a function when the result is a failure
  Future<Either<L, R>> catchError(Future<Either<L, R>> Function(L) onError) async {
    final result = await this;
    return result.fold(
      (failure) => onError(failure),
      (success) => Right(success),
    );
  }
}

/// Helper class for Either type (Left/Right pattern)
/// Used for functional error handling without exceptions
abstract class Either<L, R> {
  const Either();

  /// Apply a function to the left (error) value
  T fold<T>(T Function(L) leftFn, T Function(R) rightFn);

  /// Check if this is a Right (success) value
  bool get isRight;

  /// Check if this is a Left (error) value
  bool get isLeft;
}

class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L) leftFn, T Function(R) rightFn) {
    return leftFn(value);
  }

  @override
  bool get isRight => false;

  @override
  bool get isLeft => true;
}

class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L) leftFn, T Function(R) rightFn) {
    return rightFn(value);
  }

  @override
  bool get isRight => true;

  @override
  bool get isLeft => false;
}