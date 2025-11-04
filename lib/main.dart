import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options_prod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'core/config/environment_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/customers/presentation/providers/customer_provider.dart';
import 'features/conversations/presentation/providers/conversation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment to PROD (default)
  EnvironmentConfig.setEnvironment(Environment.prod);

  // Initialize Firebase with PROD-specific options
  await Firebase.initializeApp(
    options: FirebaseOptionsProd.currentPlatform,
  );

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

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
        provider.ChangeNotifierProvider<CustomerProvider>(
          create: (context) => DependencyInjection.customerProvider,
        ),
        provider.ChangeNotifierProvider<ConversationProvider>(
          create: (context) => DependencyInjection.conversationProvider,
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