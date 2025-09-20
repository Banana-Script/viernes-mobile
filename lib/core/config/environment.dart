enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static Environment get current {
    switch (_environment.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }

  static bool get isDevelopment => current == Environment.development;
  static bool get isProduction => current == Environment.production;

  static String get environmentName {
    switch (current) {
      case Environment.development:
        return 'development';
      case Environment.production:
        return 'production';
    }
  }
}