/// Environment configuration for different deployment environments
enum Environment {
  development,
  production,
}

/// Application configuration based on environment
class AppConfig {
  final Environment environment;
  final String baseUrl;
  final String apiVersion;
  final bool debugMode;
  final String appName;
  final Duration apiTimeout;
  final bool enableLogging;

  const AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.apiVersion,
    required this.debugMode,
    required this.appName,
    required this.apiTimeout,
    required this.enableLogging,
  });

  /// Development environment configuration
  static const AppConfig development = AppConfig._(
    environment: Environment.development,
    baseUrl: 'https://dev.viernes.com/api',
    apiVersion: 'v1',
    debugMode: true,
    appName: 'Viernes Mobile (Dev)',
    apiTimeout: Duration(seconds: 30),
    enableLogging: true,
  );

  /// Production environment configuration
  static const AppConfig production = AppConfig._(
    environment: Environment.production,
    baseUrl: 'https://api.viernes.com',
    apiVersion: 'v1',
    debugMode: false,
    appName: 'Viernes Mobile',
    apiTimeout: Duration(seconds: 15),
    enableLogging: false,
  );

  /// Current configuration instance
  static late AppConfig _instance;

  /// Initialize configuration for the given environment
  static void configure(Environment env) {
    switch (env) {
      case Environment.development:
        _instance = development;
        break;
      case Environment.production:
        _instance = production;
        break;
    }
  }

  /// Get current configuration instance
  static AppConfig get instance => _instance;

  /// Check if running in development mode
  static bool get isDev => _instance.environment == Environment.development;

  /// Check if running in production mode
  static bool get isProd => _instance.environment == Environment.production;

  /// Get full API URL
  String get fullApiUrl => '$baseUrl/$apiVersion';

}

/// Common API endpoints
class Endpoints {
  Endpoints._();

  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String register = '$auth/register';
  static const String refreshToken = '$auth/refresh';
  static const String resetPassword = '$auth/reset-password';
  static const String googleAuth = '$auth/google';

  static const String user = '/user';
  static const String profile = '$user/profile';
  static const String updateProfile = '$user/update';
  static const String toggleAvailability = '$user/toggle-availability';

  static const String conversations = '/conversations';
  static const String messages = '/messages';
  static const String sendMessage = '$messages/send';

  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String metrics = '$dashboard/metrics';

  static const String uploads = '/uploads';
  static const String uploadFile = '$uploads/file';
  static const String uploadImage = '$uploads/image';
}

/// WebSocket configuration
class WebSocketConfig {
  static String get wsUrl {
    final config = AppConfig.instance;
    final baseUrl = config.baseUrl.replaceFirst('https://', 'wss://');
    return '$baseUrl/ws';
  }

  static Duration get reconnectDelay => const Duration(seconds: 3);
  static int get maxReconnectAttempts => 5;
  static Duration get pingInterval => const Duration(seconds: 30);
}

/// Storage keys for SharedPreferences and SecureStorage
class StorageKeys {
  StorageKeys._();

  // Authentication
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String biometricEnabled = 'biometric_enabled';

  // User preferences
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';

  // Cache
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedUserProfile = 'cached_user_profile';
  static const String conversationsCache = 'conversations_cache';
}

/// Feature flags for enabling/disabling features
class FeatureFlags {
  FeatureFlags._();

  static bool get biometricAuth => true;
  static bool get pushNotifications => true;
  static bool get offlineMode => true;
  static bool get voiceCalls => false; // Coming soon
  static bool get videoCalls => false; // Coming soon
  static bool get fileSharing => true;
  static bool get darkMode => true;
  static bool get analytics => AppConfig.isProd;
  static bool get crashReporting => AppConfig.isProd;
}