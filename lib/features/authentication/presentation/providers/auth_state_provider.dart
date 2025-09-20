import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_providers.dart';
import 'auth_notifier.dart';

// Combined auth state provider that listens to Firebase auth changes
// and updates the auth notifier accordingly
final combinedAuthStateProvider = Provider<void>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  // Listen to auth state changes from the repository
  ref.listen<AsyncValue<UserEntity?>>(authStateProvider, (previous, next) {
    next.when(
      data: (user) {
        // Update the auth notifier with the new user state
        authNotifier.setUser(user);
      },
      loading: () {
        // Auth state is loading
      },
      error: (error, stackTrace) {
        // Handle auth state error
        authNotifier.clearError();
      },
    );
  });

  return;
});

// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
});

// Helper provider to get current user
final authenticatedUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

// Helper provider to check if auth is loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
});

// Helper provider to get auth error
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.error;
});