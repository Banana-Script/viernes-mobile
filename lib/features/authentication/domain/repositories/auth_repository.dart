import 'package:dartz/dartz.dart';
import '../entities/auth_result_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Firebase Authentication Methods
  Future<Either<AuthFailure, AuthResultEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, AuthResultEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, AuthResultEntity>> signInWithGoogle();

  Future<Either<AuthFailure, void>> sendPasswordResetEmail({
    required String email,
  });

  Future<Either<AuthFailure, void>> signOut();

  // User Data Management (API Integration)
  Future<Either<AuthFailure, UserEntity?>> getUserByUid(String uid);

  Future<Either<AuthFailure, UserEntity>> registerUserInAPI({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<AuthFailure, UserEntity>> getCurrentUserOrganizationalInfo();

  // User Status Management
  Future<Either<AuthFailure, bool>> getUserAvailabilityStatus(String databaseId);

  Future<Either<AuthFailure, void>> toggleUserAvailability({
    required String databaseId,
    required bool available,
  });

  // Token Management
  Future<Either<AuthFailure, String>> refreshAuthToken();

  Future<Either<AuthFailure, String?>> getStoredAuthToken();

  Future<Either<AuthFailure, void>> clearStoredAuthData();

  // Stream for auth state changes
  Stream<UserEntity?> get authStateChanges;

  // Current user getter
  UserEntity? get currentUser;
}