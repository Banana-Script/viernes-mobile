import '../config/environment_config.dart';

/// Application constants for Viernes Mobile
class AppConstants {
  // App Information (environment-specific)
  static String get appName => EnvironmentConfig.appDisplayName;
  static const String appVersion = '1.0.0';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;

  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 200);

  // Debug Configuration
  static bool get isDebugMode => EnvironmentConfig.enableDebugMode;
  static bool get isVerboseLogging => EnvironmentConfig.enableVerboseLogging;

  // Note: User roles and statuses now come from ValueDefinitionsService
  // which loads them dynamically from /values_definitions/ API
  // See: lib/core/services/value_definitions_service.dart
}