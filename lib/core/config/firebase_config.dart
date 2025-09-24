import 'package:firebase_core/firebase_core.dart';
import 'environment.dart';

/// Firebase configuration for different environments
class FirebaseConfig {
  FirebaseConfig._();

  /// Initialize Firebase with environment-specific configuration
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: _getFirebaseOptions(),
    );
  }

  /// Get Firebase options based on current environment
  static FirebaseOptions _getFirebaseOptions() {
    if (AppConfig.isDev) {
      return _developmentOptions;
    } else {
      return _productionOptions;
    }
  }

  /// Development Firebase configuration
  static const FirebaseOptions _developmentOptions = FirebaseOptions(
    apiKey: 'your-dev-api-key',
    authDomain: 'viernes-dev.firebaseapp.com',
    projectId: 'viernes-dev',
    storageBucket: 'viernes-dev.appspot.com',
    messagingSenderId: '123456789',
    appId: '1:123456789:web:abcdef123456',
    measurementId: 'G-XXXXXXXXXX',
  );

  /// Production Firebase configuration
  static const FirebaseOptions _productionOptions = FirebaseOptions(
    apiKey: 'your-prod-api-key',
    authDomain: 'viernes-prod.firebaseapp.com',
    projectId: 'viernes-prod',
    storageBucket: 'viernes-prod.appspot.com',
    messagingSenderId: '987654321',
    appId: '1:987654321:web:fedcba987654',
    measurementId: 'G-YYYYYYYYYY',
  );
}

/// Firebase collection and document references
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String conversations = 'conversations';
  static const String messages = 'messages';
  static const String analytics = 'analytics';
  static const String notifications = 'notifications';
}

/// Firebase Auth configuration
class FirebaseAuthConfig {
  FirebaseAuthConfig._();

  // Google Sign-In configuration will be handled by firebase_auth plugin
  // Additional auth providers can be configured here

  static const List<String> supportedSignInMethods = [
    'password',
    'google.com',
  ];

  static const bool enableEmailVerification = true;
  static const bool enablePasswordReset = true;
}