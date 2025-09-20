import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/toggle_user_availability_usecase.dart';
import 'auth_providers.dart';

// Auth state for the notifier
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  // Helper to clear error
  AuthState clearError() {
    return copyWith(error: null);
  }

  // Helper to set loading
  AuthState setLoading(bool loading) {
    return copyWith(isLoading: loading, error: null);
  }

  // Helper to set error
  AuthState setError(String error) {
    return copyWith(error: error, isLoading: false);
  }

  // Helper to set user
  AuthState setUser(UserEntity? user) {
    return copyWith(
      user: user,
      isAuthenticated: user != null,
      isLoading: false,
      error: null,
    );
  }
}

// Auth notifier for managing authentication state and actions
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ToggleUserAvailabilityUseCase _toggleUserAvailabilityUseCase;

  AuthNotifier({
    required LoginWithEmailUseCase loginWithEmailUseCase,
    required LoginWithGoogleUseCase loginWithGoogleUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required ToggleUserAvailabilityUseCase toggleUserAvailabilityUseCase,
  })  : _loginWithEmailUseCase = loginWithEmailUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _toggleUserAvailabilityUseCase = toggleUserAvailabilityUseCase,
        super(const AuthState());

  // Set user state (used by auth state stream)
  void setUser(UserEntity? user) {
    state = state.setUser(user);
  }

  // Clear error
  void clearError() {
    state = state.clearError();
  }

  // Login with email and password
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.setLoading(true);

    final result = await _loginWithEmailUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = state.setError(failure.message),
      (authResult) {
        // User state will be updated by the auth state stream
        state = state.setLoading(false);
      },
    );
  }

  // Login with Google
  Future<void> loginWithGoogle() async {
    state = state.setLoading(true);

    final result = await _loginWithGoogleUseCase();

    result.fold(
      (failure) => state = state.setError(failure.message),
      (authResult) {
        // User state will be updated by the auth state stream
        state = state.setLoading(false);
      },
    );
  }

  // Register new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = state.setLoading(true);

    final result = await _registerUseCase(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    result.fold(
      (failure) => state = state.setError(failure.message),
      (authResult) {
        // User state will be updated by the auth state stream
        state = state.setLoading(false);
      },
    );
  }

  // Logout
  Future<void> logout() async {
    state = state.setLoading(true);

    final result = await _logoutUseCase();

    result.fold(
      (failure) => state = state.setError(failure.message),
      (_) {
        // User state will be updated by the auth state stream
        state = state.setLoading(false);
      },
    );
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    state = state.setLoading(true);

    final result = await _resetPasswordUseCase(email: email);

    return result.fold(
      (failure) {
        state = state.setError(failure.message);
        return false;
      },
      (_) {
        state = state.setLoading(false);
        return true;
      },
    );
  }

  // Toggle user availability
  Future<void> toggleUserAvailability({
    required String databaseId,
    required bool available,
  }) async {
    final result = await _toggleUserAvailabilityUseCase(
      databaseId: databaseId,
      available: available,
    );

    result.fold(
      (failure) => state = state.setError(failure.message),
      (_) {
        // User state will be updated by the repository automatically
      },
    );
  }
}

// Provider for the auth notifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginWithEmailUseCase: ref.watch(loginWithEmailUseCaseProvider),
    loginWithGoogleUseCase: ref.watch(loginWithGoogleUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    toggleUserAvailabilityUseCase: ref.watch(toggleUserAvailabilityUseCaseProvider),
  );
});