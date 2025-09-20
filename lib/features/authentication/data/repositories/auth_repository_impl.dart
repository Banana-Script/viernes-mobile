import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_result_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../datasources/firebase_auth_service.dart';
import '../datasources/secure_storage_service.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _firebaseAuthService;
  final AuthApiService _authApiService;
  final SecureStorageService _secureStorageService;

  // Private stream controller for auth state
  final StreamController<UserEntity?> _authStateController =
      StreamController<UserEntity?>.broadcast();

  StreamSubscription<UserModel?>? _authStateSubscription;
  UserEntity? _currentUser;

  AuthRepositoryImpl({
    required FirebaseAuthService firebaseAuthService,
    required AuthApiService authApiService,
    required SecureStorageService secureStorageService,
  })  : _firebaseAuthService = firebaseAuthService,
        _authApiService = authApiService,
        _secureStorageService = secureStorageService {
    _initializeAuthStateListener();
  }

  void _initializeAuthStateListener() {
    _authStateSubscription = _firebaseAuthService.authStateChanges.listen((user) async {
      if (user != null) {
        // User is logged in, load their data from API
        final userData = await _loadUserData(user);
        _currentUser = userData;
        _authStateController.add(userData);
      } else {
        // User is logged out
        _currentUser = null;
        _authStateController.add(null);
        await _secureStorageService.clearAllAuthData();
      }
    });
  }

  Future<UserEntity?> _loadUserData(UserModel firebaseUser) async {
    try {
      // Get user data from API
      final apiUser = await _authApiService.getUserByUid(firebaseUser.uid);

      if (apiUser == null) {
        // User not found in API, return basic Firebase user
        return firebaseUser;
      }

      UserModel enrichedUser = apiUser;

      // Load availability status if user has database_id
      if (apiUser.databaseId != null) {
        try {
          final availability = await _authApiService.getUserAvailabilityStatus(apiUser.databaseId!);
          enrichedUser = apiUser.copyWith(available: availability);

          // Store availability flag for future reference
          await _secureStorageService.storeUserAvailabilityFlag(availability);
        } catch (e) {
          // If availability check fails, use default false
          enrichedUser = apiUser.copyWith(available: false);
        }

        // Load organizational info
        try {
          final orgInfo = await _authApiService.getCurrentUserOrganizationalInfo();
          enrichedUser = enrichedUser.copyWith(
            organizationalRole: orgInfo.organizationalRole,
            organizationalStatus: orgInfo.organizationalStatus,
            organizationId: orgInfo.organizationId,
          );
        } catch (e) {
          // Organizational info loading failed, continue without it
        }
      }

      // Store enriched user data
      await _secureStorageService.storeUserData(enrichedUser);

      return enrichedUser;
    } catch (e) {
      // If API calls fail, return the Firebase user
      return firebaseUser;
    }
  }

  @override
  Future<Either<AuthFailure, AuthResultEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuthService.signInWithEmailAndPassword(email, password);

      // Store tokens
      await _secureStorageService.storeAuthToken(result.idToken);
      if (result.refreshToken != null) {
        await _secureStorageService.storeRefreshToken(result.refreshToken!);
      }

      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailureModel.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, AuthResultEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuthService.createUserWithEmailAndPassword(email, password);

      // Store tokens
      await _secureStorageService.storeAuthToken(result.idToken);
      if (result.refreshToken != null) {
        await _secureStorageService.storeRefreshToken(result.refreshToken!);
      }

      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailureModel.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, AuthResultEntity>> signInWithGoogle() async {
    try {
      final result = await _firebaseAuthService.signInWithGoogle();

      // Store tokens
      await _secureStorageService.storeAuthToken(result.idToken);
      if (result.refreshToken != null) {
        await _secureStorageService.storeRefreshToken(result.refreshToken!);
      }

      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailureModel.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailureModel.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await _firebaseAuthService.signOut();
      await _secureStorageService.clearAllAuthData();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getUserByUid(String uid) async {
    try {
      final user = await _authApiService.getUserByUid(uid);
      return Right(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Right(null);
      }
      return Left(AuthFailureModel.network(e.message ?? 'Network error'));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> registerUserInAPI({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final user = await _authApiService.registerUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      return Right(user);
    } on DioException catch (e) {
      String message = 'Registration failed';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        message = e.response!.data['message'];
      }
      return Left(AuthFailureModel.server(message));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> getCurrentUserOrganizationalInfo() async {
    try {
      final user = await _authApiService.getCurrentUserOrganizationalInfo();
      return Right(user);
    } on DioException catch (e) {
      return Left(AuthFailureModel.server(e.message ?? 'Failed to get organizational info'));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> getUserAvailabilityStatus(String databaseId) async {
    try {
      final availability = await _authApiService.getUserAvailabilityStatus(databaseId);
      return Right(availability);
    } on DioException catch (e) {
      return Left(AuthFailureModel.server(e.message ?? 'Failed to get availability status'));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, void>> toggleUserAvailability({
    required String databaseId,
    required bool available,
  }) async {
    try {
      await _authApiService.toggleUserAvailability(databaseId, available);

      // Update local storage
      await _secureStorageService.storeUserAvailabilityFlag(available);

      // Update current user if it matches
      if (_currentUser != null && _currentUser!.databaseId == databaseId) {
        final updatedUser = (_currentUser as UserModel).copyWith(available: available);
        _currentUser = updatedUser;
        _authStateController.add(updatedUser);
        await _secureStorageService.storeUserData(updatedUser);
      }

      return const Right(null);
    } on DioException catch (e) {
      return Left(AuthFailureModel.server(e.message ?? 'Failed to toggle availability'));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, String>> refreshAuthToken() async {
    try {
      final token = await _firebaseAuthService.refreshCurrentUserToken();
      await _secureStorageService.storeAuthToken(token);
      return Right(token);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailureModel.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, String?>> getStoredAuthToken() async {
    try {
      final token = await _secureStorageService.getAuthToken();
      return Right(token);
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Future<Either<AuthFailure, void>> clearStoredAuthData() async {
    try {
      await _secureStorageService.clearAllAuthData();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailureModel.fromException(e as Exception));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _authStateController.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  void dispose() {
    _authStateSubscription?.cancel();
    _authStateController.close();
  }
}