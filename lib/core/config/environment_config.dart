/// Environment configuration for Viernes Mobile
/// Supports multiple environments: dev, prod
enum Environment {
  dev,
  prod,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.prod;

  static Environment get current => _currentEnvironment;

  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  static bool get isDev => _currentEnvironment == Environment.dev;
  static bool get isProd => _currentEnvironment == Environment.prod;

  // App Configuration
  static String get appName {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'Viernes Dev';
      case Environment.prod:
        return 'Viernes';
    }
  }

  static String get appDisplayName {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'Viernes Mobile - Dev';
      case Environment.prod:
        return 'Viernes Mobile';
    }
  }

  static String get bundleId {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'com.bananascript.viernesforbusiness.dev';
      case Environment.prod:
        return 'com.bananascript.viernesforbusiness';
    }
  }

  // Firebase Configuration
  static String get firebaseProjectId {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'viernes-for-business-dev';
      case Environment.prod:
        return 'viernes-for-business';
    }
  }

  // API Configuration (add your API endpoints here)
  static String get apiBaseUrl {
    switch (_currentEnvironment) {
      case Environment.dev:
        return 'https://bot.dev.viernes-for-business.bananascript.io';
      case Environment.prod:
        return 'https://bot.viernes-for-business.bananascript.io';
    }
  }

  // Debug Configuration
  static bool get enableDebugMode {
    switch (_currentEnvironment) {
      case Environment.dev:
        return true;
      case Environment.prod:
        return false;
    }
  }

  // Logging Configuration
  static bool get enableVerboseLogging {
    switch (_currentEnvironment) {
      case Environment.dev:
        return true;
      case Environment.prod:
        return false;
    }
  }
}