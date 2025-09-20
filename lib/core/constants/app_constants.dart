class AppConstants {
  // App Info
  static const String appName = 'Viernes';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://bot.dev.viernes-for-business.bananascript.io');
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Authentication
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String organizationDataKey = 'organization_data';

  // Local Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // Session
  static const int sessionTimeoutMinutes = 240; // 4 hours

  // Socket/SSE
  static const int reconnectAttempts = 3;
  static const int reconnectDelaySeconds = 5;
}