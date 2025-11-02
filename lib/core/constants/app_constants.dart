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

  // User Roles
  static const int customerRoleId = 2; // Customer role
  static const int agentRoleId = 1; // Agent role

  // User Status
  static const int activeStatusId = 1; // Active status
  static const int inactiveStatusId = 2; // Inactive status
}