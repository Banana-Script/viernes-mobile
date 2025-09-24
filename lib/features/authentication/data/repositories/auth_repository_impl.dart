import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/auth_result_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../datasources/firebase_auth_service.dart';
import '../datasources/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _firebaseAuthService;
  final AuthApiService _authApiService;
  final SecureStorageService _secureStorageService;
  final LocalAuthentication _localAuth;

  AuthRepositoryImpl({
    required FirebaseAuthService firebaseAuthService,
    required AuthApiService authApiService,
    required SecureStorageService secureStorageService,
    LocalAuthentication? localAuth,
  })  : _firebaseAuthService = firebaseAuthService,
        _authApiService = authApiService,
        _secureStorageService = secureStorageService,
        _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<Either<Failure, AuthResultEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Sign in with Firebase
      final firebaseUser = await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Get Firebase ID token
      final firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (firebaseToken == null) {
        return const Left(AuthFailure(message: 'Failed to get Firebase token'));
      }

      // Step 3: Validate with backend
      final authResult = await _authApiService.validateFirebaseToken(firebaseToken);

      // Step 4: Store auth data
      await _secureStorageService.storeAuthResult(authResult);

      return Right(authResult.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Sign in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResultEntity>> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google via Firebase
      final firebaseUser = await _firebaseAuthService.signInWithGoogle();

      // Step 2: Get Firebase ID token
      final firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (firebaseToken == null) {
        return const Left(AuthFailure(message: 'Failed to get Firebase token'));
      }

      // Step 3: Validate with backend
      final authResult = await _authApiService.validateFirebaseToken(firebaseToken);

      // Step 4: Store auth data
      await _secureStorageService.storeAuthResult(authResult);

      return Right(authResult.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Google sign in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Password reset failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Get access token before clearing storage
      final accessToken = await _secureStorageService.getAccessToken();

      // Sign out from Firebase
      await _firebaseAuthService.signOut();

      // Notify backend (best effort)
      if (accessToken != null) {
        await _authApiService.logout(accessToken);
      }

      // Clear stored auth data
      await _secureStorageService.clearAuthData();

      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final authResult = await _secureStorageService.getAuthResult();
      if (authResult == null) return const Right(null);

      // Check if token is expired
      if (authResult.toEntity().isTokenExpired) {
        // Try to refresh token
        final refreshResult = await refreshToken();
        return refreshResult.fold(
          (failure) => const Right(null), // Return null if refresh failed
          (newAuthResult) => Right(newAuthResult.user),
        );
      }

      return Right(authResult.user.toEntity());
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResultEntity>> refreshToken() async {
    try {
      final refreshToken = await _secureStorageService.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthFailure(message: 'No refresh token available'));
      }

      final authResult = await _authApiService.refreshToken(refreshToken);
      await _secureStorageService.storeAuthResult(authResult);

      return Right(authResult.toEntity());
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Token refresh failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> toggleUserAvailability(bool isAvailable) async {
    try {
      final updatedUser = await _authApiService.updateUserAvailability(isAvailable);

      // Update stored auth result with new user data
      final storedAuthResult = await _secureStorageService.getAuthResult();
      if (storedAuthResult != null) {
        final updatedAuthResult = storedAuthResult.copyWith(user: updatedUser);
        await _secureStorageService.storeAuthResult(updatedAuthResult);
      }

      return Right(updatedUser.toEntity());
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to toggle availability: ${e.toString()}'));
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuthService.authStateChanges;

  @override
  Future<bool> isAuthenticated() async {
    try {
      final authResult = await _secureStorageService.getAuthResult();
      if (authResult == null) return false;

      // Check if token is not expired
      return !authResult.toEntity().isTokenExpired;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthResultEntity?> getStoredAuthResult() async {
    try {
      final authResult = await _secureStorageService.getAuthResult();
      return authResult?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorageService.storeBiometricEnabled(enabled);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Failed to set biometric setting: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      return await _secureStorageService.getBiometricEnabled();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometrics() async {
    try {
      // Check if biometric authentication is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return const Left(PermissionFailure(message: 'Biometric authentication not available'));
      }

      // Check if biometrics are enrolled
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return const Left(PermissionFailure(message: 'No biometrics enrolled'));
      }

      // Authenticate
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return Right(didAuthenticate);
    } catch (e) {
      return Left(PermissionFailure(message: 'Biometric authentication failed: ${e.toString()}'));
    }
  }
}