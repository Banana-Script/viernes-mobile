import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options_prod.dart';
import 'core/config/environment_config.dart';
import 'core/theme/theme_manager.dart';
import 'app.dart';

void main() async {
  // Preserve native splash screen during initialization
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set environment to PROD
  EnvironmentConfig.setEnvironment(Environment.prod);

  // Initialize Firebase with PROD-specific options
  await Firebase.initializeApp(
    options: FirebaseOptionsProd.currentPlatform,
  );

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
