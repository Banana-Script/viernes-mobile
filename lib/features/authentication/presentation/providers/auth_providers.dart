import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_api_service.dart';
import '../../data/datasources/firebase_auth_service.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/toggle_user_availability_usecase.dart';
import '../../../../core/network/dio_providers.dart';

// Data source providers
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthServiceImpl();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageServiceImpl();
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return AuthApiServiceImpl(dio: dio);
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthServiceProvider);
  final authApi = ref.watch(authApiServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);

  return AuthRepositoryImpl(
    firebaseAuthService: firebaseAuth,
    authApiService: authApi,
    secureStorageService: secureStorage,
  );
});

// Use case providers
final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithEmailUseCase(repository);
});

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithGoogleUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

final toggleUserAvailabilityUseCaseProvider = Provider<ToggleUserAvailabilityUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ToggleUserAvailabilityUseCase(repository);
});

// Auth state provider - streams the current authentication state
final authStateProvider = StreamProvider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.currentUser;
});