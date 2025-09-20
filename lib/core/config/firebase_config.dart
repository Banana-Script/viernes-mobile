import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'environment.dart';

class FirebaseConfig {
  // Development configuration
  static const Map<String, String> _devConfig = {
    'apiKey': 'AIzaSyCCoHihPpB22eiCfV1wKzIPzdd1wQ6ALKI',
    'authDomain': 'viernes-for-business-dev.firebaseapp.com',
    'projectId': 'viernes-for-business-dev',
    'storageBucket': 'viernes-for-business-dev.appspot.com',
    'messagingSenderId': '502544225919',
    'appId': '1:502544225919:android:45b4b924b39a4bc065514a',
    'iosAppId': '1:502544225919:ios:490ebb9426630b9b65514a',
  };

  // Production configuration
  static const Map<String, String> _prodConfig = {
    'apiKey': 'AIzaSyBITZeWe2xsI5tdj8Q4QIJezCCoIkG8Wlc',
    'authDomain': 'viernes-for-business.firebaseapp.com',
    'projectId': 'viernes-for-business',
    'storageBucket': 'viernes-for-business.appspot.com',
    'messagingSenderId': '131219866555',
    'appId': '1:131219866555:android:2077ded02b9e551a7d7a9e',
    'iosAppId': '1:131219866555:ios:9c77ca5012accf027d7a9e',
  };

  static Map<String, String> get _currentConfig {
    return EnvironmentConfig.isProduction ? _prodConfig : _devConfig;
  }

  static String get bundleId {
    return EnvironmentConfig.isProduction
        ? 'com.bananascript.viernesforbusiness'
        : 'com.bananascript.viernesforbusiness.dev';
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
    appId: _currentConfig['iosAppId']!,
    iosBundleId: bundleId,
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _currentConfig['apiKey']!,
    authDomain: _currentConfig['authDomain']!,
    projectId: _currentConfig['projectId']!,
    storageBucket: _currentConfig['storageBucket']!,
    messagingSenderId: _currentConfig['messagingSenderId']!,
    appId: _currentConfig['iosAppId']!,
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