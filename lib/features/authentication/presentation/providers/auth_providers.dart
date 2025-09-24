import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/auth_api_service.dart';
import '../../data/datasources/firebase_auth_service.dart';
import '../../data/datasources/secure_storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/authenticate_with_biometrics_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/toggle_user_availability_usecase.dart';
import 'auth_notifier.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_state_provider.dart';

// Datasources
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthServiceImpl();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageServiceImpl();
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthApiServiceImpl(dioClient: dioClient);
});

final localAuthProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuthService: ref.watch(firebaseAuthServiceProvider),
    authApiService: ref.watch(authApiServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
    localAuth: ref.watch(localAuthProvider),
  );
});

// Use Cases
final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>((ref) {
  return LoginWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  return LoginWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final toggleUserAvailabilityUseCaseProvider = Provider<ToggleUserAvailabilityUseCase>((ref) {
  return ToggleUserAvailabilityUseCase(ref.watch(authRepositoryProvider));
});

final authenticateWithBiometricsUseCaseProvider = Provider<AuthenticateWithBiometricsUseCase>((ref) {
  return AuthenticateWithBiometricsUseCase(ref.watch(authRepositoryProvider));
});

// Auth State Management
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginWithEmailUseCase: ref.watch(loginWithEmailUseCaseProvider),
    loginWithGoogleUseCase: ref.watch(loginWithGoogleUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    toggleUserAvailabilityUseCase: ref.watch(toggleUserAvailabilityUseCaseProvider),
    authenticateWithBiometricsUseCase: ref.watch(authenticateWithBiometricsUseCaseProvider),
    localAuth: ref.watch(localAuthProvider),
  );
});

// Convenience providers
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).error;
});

final isBiometricAvailableProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isBiometricAvailable;
});

final canUseBiometricProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).canUseBiometric;
});

// Firebase Auth State Stream Provider
final firebaseAuthStateProvider = StreamProvider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// Auth State Change Stream Provider
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  // Create a stream controller to manually emit state changes
  late final StreamController<AuthState> controller;

  controller = StreamController<AuthState>.broadcast(
    onListen: () {
      // Emit current state immediately
      controller.add(ref.read(authNotifierProvider));
    },
  );

  // Listen to state changes and emit them
  ref.listen(authNotifierProvider, (previous, next) {
    if (!controller.isClosed) {
      controller.add(next);
    }
  });

  // Clean up when provider is disposed
  ref.onDispose(() {
    controller.close();
  });

  return controller.stream;
});