import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/environment.dart';
import 'main.dart';

/// Production environment entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure for production environment
  AppConfig.configure(Environment.production);

  // Run the app
  runApp(
    const ProviderScope(
      child: ViernesApp(),
    ),
  );
}