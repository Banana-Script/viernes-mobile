import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options_dev.dart';
import 'core/config/environment_config.dart';
import 'core/theme/theme_manager.dart';
import 'core/services/fcm_message_handler.dart';
import 'app.dart';

void main() async {
  // Preserve native splash screen during initialization
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set environment to DEV
  EnvironmentConfig.setEnvironment(Environment.dev);

  // Initialize Firebase with DEV-specific options
  await Firebase.initializeApp(
    options: FirebaseOptionsDev.currentPlatform,
  );

  // Register FCM background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize common app services
  final sharedPreferences = await initializeApp();

  // Remove native splash - Flutter splash will take over
  FlutterNativeSplash.remove();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ViernesApp(),
    ),
  );
}
