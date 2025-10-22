import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options_dev.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'core/config/environment_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main/presentation/pages/main_page.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Set environment to DEV
  EnvironmentConfig.setEnvironment(Environment.dev);

  // Initialize Firebase with DEV-specific options
  await Firebase.initializeApp(
    options: FirebaseOptionsDev.currentPlatform,
  );

  // Initialize dependency injection
  DependencyInjection.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ViernesApp(),
    ),
  );
}

class ViernesApp extends ConsumerWidget {
  const ViernesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeManagerProvider);

    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<auth_provider.AuthProvider>(
          create: (context) => DependencyInjection.authProvider,
        ),
        provider.ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DependencyInjection.dashboardProvider,
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
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
    return provider.Consumer<auth_provider.AuthProvider>(
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
            return const MainPage();
          case auth_provider.AuthStatus.unauthenticated:
          case auth_provider.AuthStatus.error:
            return const LoginPage();
          case auth_provider.AuthStatus.loading:
            // Show current screen with loading overlay
            return authProvider.user != null ? const MainPage() : const LoginPage();
          default:
            return const LoginPage();
        }
      },
    );
  }
}