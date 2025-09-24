import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../domain/usecases/authenticate_with_biometrics_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/toggle_user_availability_usecase.dart';
import 'auth_state_provider.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LogoutUseCase _logoutUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ToggleUserAvailabilityUseCase _toggleUserAvailabilityUseCase;
  final AuthenticateWithBiometricsUseCase _authenticateWithBiometricsUseCase;
  final LocalAuthentication _localAuth;

  AuthNotifier({
    required LoginWithEmailUseCase loginWithEmailUseCase,
    required LoginWithGoogleUseCase loginWithGoogleUseCase,
    required LogoutUseCase logoutUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ToggleUserAvailabilityUseCase toggleUserAvailabilityUseCase,
    required AuthenticateWithBiometricsUseCase authenticateWithBiometricsUseCase,
    LocalAuthentication? localAuth,
  })  : _loginWithEmailUseCase = loginWithEmailUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        _logoutUseCase = logoutUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _toggleUserAvailabilityUseCase = toggleUserAvailabilityUseCase,
        _authenticateWithBiometricsUseCase = authenticateWithBiometricsUseCase,
        _localAuth = localAuth ?? LocalAuthentication(),
        super(const AuthState());

  /// Initialize auth state on app start
  Future<void> initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Check biometric availability
      final isBiometricAvailable = await _localAuth.canCheckBiometrics;

      // Get current user
      final result = await _getCurrentUserUseCase();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isInitialized: true,
            isBiometricAvailable: isBiometricAvailable,
            error: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            user: user,
            isLoading: false,
            isInitialized: true,
            isBiometricAvailable: isBiometricAvailable,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: 'Failed to initialize authentication: ${e.toString()}',
      );
    }
  }

  /// Login with email and password
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginWithEmailUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (authResult) {
        state = state.copyWith(
          user: authResult.user,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Login with Google
  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginWithGoogleUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (authResult) {
        state = state.copyWith(
          user: authResult.user,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _resetPasswordUseCase(email);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        // Even if logout fails, clear local state
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          user: null,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  /// Toggle user availability status
  Future<void> toggleUserAvailability(bool isAvailable) async {
    if (state.user == null) return;

    final previousUser = state.user!;

    // Optimistic update
    state = state.copyWith(
      user: previousUser.copyWith(isAvailable: isAvailable),
    );

    final result = await _toggleUserAvailabilityUseCase(isAvailable);

    result.fold(
      (failure) {
        // Revert on failure
        state = state.copyWith(
          user: previousUser,
          error: failure.message,
        );
      },
      (updatedUser) {
        state = state.copyWith(
          user: updatedUser,
          error: null,
        );
      },
    );
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    if (!state.isBiometricAvailable) return false;

    final result = await _authenticateWithBiometricsUseCase();

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) => success,
    );
  }

  /// Set biometric authentication enabled
  void setBiometricEnabled(bool enabled) {
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}