import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/auth_result_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, AuthResultEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Sign out user
  Future<Either<Failure, void>> signOut();

  /// Get current user from cache
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Refresh auth token
  Future<Either<Failure, AuthResultEntity>> refreshToken();

  /// Toggle user availability
  Future<Either<Failure, UserEntity>> toggleUserAvailability(bool isAvailable);

  /// Get authentication state stream
  Stream<User?> get authStateChanges;

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get stored auth result
  Future<AuthResultEntity?> getStoredAuthResult();

  /// Enable/disable biometric authentication
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled);

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled();

  /// Authenticate with biometrics
  Future<Either<Failure, bool>> authenticateWithBiometrics();
}