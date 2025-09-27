// File generated for PROD environment
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for PROD environment.
/// Project: viernes-for-business
class FirebaseOptionsProd {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options for PROD environment have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase options for PROD environment have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase options for PROD environment have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options for PROD environment have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'Firebase options for PROD environment are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBITZeWe2xsI5tdj8Q4QIJezCCoIkG8Wlc',
    appId: '1:131219866555:android:2077ded02b9e551a7d7a9e',
    messagingSenderId: '131219866555',
    projectId: 'viernes-for-business',
    storageBucket: 'viernes-for-business.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDEbUE0QZSnrEIgiq7HtPtL-JAuOVul3pc',
    appId: '1:131219866555:ios:9c77ca5012accf027d7a9e',
    messagingSenderId: '131219866555',
    projectId: 'viernes-for-business',
    storageBucket: 'viernes-for-business.appspot.com',
    iosBundleId: 'com.bananascript.viernesforbusiness',
  );
}