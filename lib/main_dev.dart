import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/environment.dart';
import 'main.dart';

/// Development environment entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure for development environment
  AppConfig.configure(Environment.development);

  // Run the app
  runApp(
    const ProviderScope(
      child: ViernesApp(),
    ),
  );
}