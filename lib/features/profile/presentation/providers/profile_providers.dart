import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../../domain/usecases/toggle_user_availability.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/user_status_service.dart';
import '../../data/datasources/profile_local_datasource.dart';
import '../../../../shared/providers/app_providers.dart';

// === REPOSITORY PROVIDERS ===

/// User Status Service provider
final userStatusServiceProvider = Provider<UserStatusService>((ref) {
  return UserStatusService();
});

/// Profile Local Data Source provider
final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  const secureStorage = FlutterSecureStorage();
  return ProfileLocalDataSource(prefs, secureStorage);
});

/// Profile Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final userStatusService = ref.watch(userStatusServiceProvider);
  final localDataSource = ref.watch(profileLocalDataSourceProvider);
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseStorage = FirebaseStorage.instance;

  return ProfileRepositoryImpl(
    userStatusService,
    localDataSource,
    firebaseAuth,
    firebaseStorage,
  );
});

// === USE CASE PROVIDERS ===

/// User Profile Use Cases
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});

final updateUserAvatarUseCaseProvider = Provider<UpdateUserAvatarUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateUserAvatarUseCase(repository);
});

final deleteUserAvatarUseCaseProvider = Provider<DeleteUserAvatarUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return DeleteUserAvatarUseCase(repository);
});

/// User Availability Use Cases
final toggleUserAvailabilityUseCaseProvider = Provider<ToggleUserAvailabilityUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ToggleUserAvailabilityUseCase(repository);
});

final getUserAvailabilityUseCaseProvider = Provider<GetUserAvailabilityUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserAvailabilityUseCase(repository);
});

/// User Preferences Use Cases
final getUserPreferencesUseCaseProvider = Provider<GetUserPreferencesUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserPreferencesUseCase(repository);
});

final saveUserPreferencesUseCaseProvider = Provider<SaveUserPreferencesUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return SaveUserPreferencesUseCase(repository);
});

/// Account Management Use Cases
final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ChangePasswordUseCase(repository);
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return SignOutUseCase(repository);
});

/// App Info Use Case
final getAppInfoUseCaseProvider = Provider<GetAppInfoUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetAppInfoUseCase(repository);
});

// === STATE PROVIDERS ===

/// User Profile State Provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final getUserProfileUseCase = ref.watch(getUserProfileUseCaseProvider);
  final updateUserProfileUseCase = ref.watch(updateUserProfileUseCaseProvider);
  return UserProfileNotifier(getUserProfileUseCase, updateUserProfileUseCase);
});

/// User Availability State Provider
final userAvailabilityProvider = StateNotifierProvider<UserAvailabilityNotifier, AsyncValue<bool>>((ref) {
  final getUserAvailabilityUseCase = ref.watch(getUserAvailabilityUseCaseProvider);
  final toggleUserAvailabilityUseCase = ref.watch(toggleUserAvailabilityUseCaseProvider);
  return UserAvailabilityNotifier(getUserAvailabilityUseCase, toggleUserAvailabilityUseCase);
});

/// User Preferences State Provider
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, AsyncValue<UserPreferences>>((ref) {
  final getUserPreferencesUseCase = ref.watch(getUserPreferencesUseCaseProvider);
  final saveUserPreferencesUseCase = ref.watch(saveUserPreferencesUseCaseProvider);
  return UserPreferencesNotifier(getUserPreferencesUseCase, saveUserPreferencesUseCase);
});

/// App Info State Provider
final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  final getAppInfoUseCase = ref.watch(getAppInfoUseCaseProvider);
  final result = await getAppInfoUseCase();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (appInfo) => appInfo,
  );
});

// === STATE NOTIFIERS ===

/// User Profile State Notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  UserProfileNotifier(this._getUserProfileUseCase, this._updateUserProfileUseCase)
      : super(const AsyncValue.loading()) {
    loadUserProfile();
  }

  /// Load user profile
  Future<void> loadUserProfile() async {
    state = const AsyncValue.loading();

    final result = await _getUserProfileUseCase();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    state = const AsyncValue.loading();

    final result = await _updateUserProfileUseCase(profile);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (updatedProfile) {
        state = AsyncValue.data(updatedProfile);
        return true;
      },
    );
  }

  /// Refresh user profile
  Future<void> refresh() async {
    await loadUserProfile();
  }
}

/// User Availability State Notifier
class UserAvailabilityNotifier extends StateNotifier<AsyncValue<bool>> {
  final GetUserAvailabilityUseCase _getUserAvailabilityUseCase;
  final ToggleUserAvailabilityUseCase _toggleUserAvailabilityUseCase;

  UserAvailabilityNotifier(this._getUserAvailabilityUseCase, this._toggleUserAvailabilityUseCase)
      : super(const AsyncValue.loading()) {
    loadUserAvailability();
  }

  /// Load user availability status
  Future<void> loadUserAvailability() async {
    state = const AsyncValue.loading();

    final result = await _getUserAvailabilityUseCase();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (isAvailable) => state = AsyncValue.data(isAvailable),
    );
  }

  /// Toggle user availability
  Future<bool> toggleAvailability() async {
    final currentAvailability = state.value ?? false;

    // Optimistic update
    state = AsyncValue.data(!currentAvailability);

    final result = await _toggleUserAvailabilityUseCase();
    return result.fold(
      (failure) {
        // Revert on failure
        state = AsyncValue.data(currentAvailability);
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (newAvailability) {
        state = AsyncValue.data(newAvailability);
        return true;
      },
    );
  }

  /// Set specific availability status
  Future<bool> setAvailability(bool isAvailable) async {
    final currentAvailability = state.value ?? false;

    // Don't make API call if status is already the same
    if (currentAvailability == isAvailable) return true;

    // Optimistic update
    state = AsyncValue.data(isAvailable);

    final result = await _toggleUserAvailabilityUseCase.setAvailability(isAvailable);
    return result.fold(
      (failure) {
        // Revert on failure
        state = AsyncValue.data(currentAvailability);
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (newAvailability) {
        state = AsyncValue.data(newAvailability);
        return true;
      },
    );
  }

  /// Refresh availability status
  Future<void> refresh() async {
    await loadUserAvailability();
  }
}

/// User Preferences State Notifier
class UserPreferencesNotifier extends StateNotifier<AsyncValue<UserPreferences>> {
  final GetUserPreferencesUseCase _getUserPreferencesUseCase;
  final SaveUserPreferencesUseCase _saveUserPreferencesUseCase;

  UserPreferencesNotifier(this._getUserPreferencesUseCase, this._saveUserPreferencesUseCase)
      : super(const AsyncValue.loading()) {
    loadUserPreferences();
  }

  /// Load user preferences
  Future<void> loadUserPreferences() async {
    state = const AsyncValue.loading();

    final result = await _getUserPreferencesUseCase();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (preferences) => state = AsyncValue.data(preferences),
    );
  }

  /// Save user preferences
  Future<bool> saveUserPreferences(UserPreferences preferences) async {
    // Optimistic update
    state = AsyncValue.data(preferences);

    final result = await _saveUserPreferencesUseCase(preferences);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) => true,
    );
  }

  /// Update specific preference
  Future<bool> updatePreference({
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? timezone,
  }) async {
    final currentPreferences = state.value;
    if (currentPreferences == null) return false;

    final updatedPreferences = currentPreferences.copyWith(
      themeMode: themeMode,
      language: language,
      notificationsEnabled: notificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      timezone: timezone,
    );

    return await saveUserPreferences(updatedPreferences);
  }
}