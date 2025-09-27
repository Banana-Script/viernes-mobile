import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options_dev.dart';
import 'core/theme/app_theme.dart';
import 'core/config/environment_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment to DEV
  EnvironmentConfig.setEnvironment(Environment.dev);

  // Initialize Firebase with DEV-specific options
  await Firebase.initializeApp(
    options: FirebaseOptionsDev.currentPlatform,
  );

  // Initialize dependency injection
  DependencyInjection.initialize();

  runApp(const ViernesApp());
}

class ViernesApp extends StatelessWidget {
  const ViernesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<auth_provider.AuthProvider>(
      create: (context) => DependencyInjection.authProvider,
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AuthenticationWrapper(),
        debugShowCheckedModeBanner: AppConstants.isDebugMode,
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<auth_provider.AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking authentication state
        if (authProvider.status == auth_provider.AuthStatus.initial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on authentication status
        switch (authProvider.status) {
          case auth_provider.AuthStatus.authenticated:
            return const HomePage();
          case auth_provider.AuthStatus.unauthenticated:
          case auth_provider.AuthStatus.error:
            return const LoginPage();
          case auth_provider.AuthStatus.loading:
            // Show current screen with loading overlay
            return authProvider.user != null ? const HomePage() : const LoginPage();
          default:
            return const LoginPage();
        }
      },
    );
  }
}