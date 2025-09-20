/// Profile feature dependency injection
/// This file provides easy access to all profile-related providers and use cases

// Export all providers
export 'presentation/providers/profile_providers.dart';

// Export all widgets
export 'presentation/widgets/profile_widgets.dart';
export 'presentation/widgets/user_availability_widget.dart';

// Export all pages
export 'presentation/pages/enhanced_profile_page.dart';

// Export domain entities
export 'domain/entities/user_profile.dart';
export 'domain/entities/app_info.dart';

// Export use cases for external access if needed
export 'domain/usecases/profile_usecases.dart';
export 'domain/usecases/toggle_user_availability.dart';

/// Profile feature module
/// Contains all the dependencies and providers for the profile feature
class ProfileFeatureModule {
  static const String moduleName = 'profile';

  /// List of all providers that need to be registered
  static const List<String> providers = [
    'userStatusServiceProvider',
    'profileLocalDataSourceProvider',
    'profileRepositoryProvider',
    'getUserProfileUseCaseProvider',
    'updateUserProfileUseCaseProvider',
    'updateUserAvatarUseCaseProvider',
    'deleteUserAvatarUseCaseProvider',
    'toggleUserAvailabilityUseCaseProvider',
    'getUserAvailabilityUseCaseProvider',
    'getUserPreferencesUseCaseProvider',
    'saveUserPreferencesUseCaseProvider',
    'changePasswordUseCaseProvider',
    'deleteAccountUseCaseProvider',
    'signOutUseCaseProvider',
    'getAppInfoUseCaseProvider',
    'userProfileProvider',
    'userAvailabilityProvider',
    'userPreferencesProvider',
    'appInfoProvider',
  ];

  /// Feature-specific routes
  static const Map<String, String> routes = {
    '/profile': 'EnhancedProfilePage',
    '/profile/settings': 'EnhancedProfilePage',
  };
}