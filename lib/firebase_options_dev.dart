// File generated for DEV environment
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for DEV environment.
/// Project: viernes-for-business-dev
class FirebaseOptionsDev {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options for DEV environment have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase options for DEV environment have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase options for DEV environment have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options for DEV environment have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'Firebase options for DEV environment are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCoHihPpB22eiCfV1wKzIPzdd1wQ6ALKI',
    appId: '1:502544225919:android:45b4b924b39a4bc065514a',
    messagingSenderId: '502544225919',
    projectId: 'viernes-for-business-dev',
    storageBucket: 'viernes-for-business-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLapUxVaa8pqbm3HN_hJAZdOsN5stzpaY',
    appId: '1:502544225919:ios:490ebb9426630b9b65514a',
    messagingSenderId: '502544225919',
    projectId: 'viernes-for-business-dev',
    storageBucket: 'viernes-for-business-dev.appspot.com',
    iosBundleId: 'com.bananascript.viernesforbusiness.dev',
  );
}