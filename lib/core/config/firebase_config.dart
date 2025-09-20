import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'environment.dart';

class FirebaseConfig {
  // Development configuration
  static const Map<String, String> _devConfig = {
    'apiKey': 'AIzaSyDEVELOPMENT-TEST-KEY-PLACEHOLDER',
    'authDomain': 'viernes-dev.firebaseapp.com',
    'projectId': 'viernes-dev',
    'storageBucket': 'viernes-dev.appspot.com',
    'messagingSenderId': '123456789',
    'appId': '1:123456789:android:abcdef123456',
    'iosClientId': '123456789-abcdef.apps.googleusercontent.com',
  };

  // Production configuration
  static const Map<String, String> _prodConfig = {
    'apiKey': 'AIzaSyPRODUCTION-TEST-KEY-PLACEHOLDER',
    'authDomain': 'viernes-prod.firebaseapp.com',
    'projectId': 'viernes-prod',
    'storageBucket': 'viernes-prod.appspot.com',
    'messagingSenderId': '987654321',
    'appId': '1:987654321:android:fedcba654321',
    'iosClientId': '987654321-fedcba.apps.googleusercontent.com',
  };

  static Map<String, String> get _currentConfig {
    return EnvironmentConfig.isProduction ? _prodConfig : _devConfig;
  }

  static String get bundleId {
    return EnvironmentConfig.isProduction
        ? 'com.bananascript.viernes.viernesMobile'
        : 'com.bananascript.viernes.viernesMobile.dev';
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _currentConfig['apiKey']!,
    authDomain: _currentConfig['authDomain']!,
    projectId: _currentConfig['projectId']!,
    storageBucket: _currentConfig['storageBucket']!,
    messagingSenderId: _currentConfig['messagingSenderId']!,
    appId: _currentConfig['appId']!,
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _currentConfig['apiKey']!,
    authDomain: _currentConfig['authDomain']!,
    projectId: _currentConfig['projectId']!,
    storageBucket: _currentConfig['storageBucket']!,
    messagingSenderId: _currentConfig['messagingSenderId']!,
    appId: _currentConfig['appId']!,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _currentConfig['apiKey']!,
    authDomain: _currentConfig['authDomain']!,
    projectId: _currentConfig['projectId']!,
    storageBucket: _currentConfig['storageBucket']!,
    messagingSenderId: _currentConfig['messagingSenderId']!,
    appId: _currentConfig['appId']!,
    iosClientId: _currentConfig['iosClientId']!,
    iosBundleId: bundleId,
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _currentConfig['apiKey']!,
    authDomain: _currentConfig['authDomain']!,
    projectId: _currentConfig['projectId']!,
    storageBucket: _currentConfig['storageBucket']!,
    messagingSenderId: _currentConfig['messagingSenderId']!,
    appId: _currentConfig['appId']!,
    iosClientId: _currentConfig['iosClientId']!,
    iosBundleId: bundleId,
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _currentConfig['apiKey']!,
    authDomain: _currentConfig['authDomain']!,
    projectId: _currentConfig['projectId']!,
    storageBucket: _currentConfig['storageBucket']!,
    messagingSenderId: _currentConfig['messagingSenderId']!,
    appId: _currentConfig['appId']!,
  );
}