import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options_prod.dart';
import 'core/theme/app_theme.dart';
import 'core/config/environment_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main/presentation/pages/main_page.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/customers/presentation/providers/customer_provider.dart';
import 'features/conversations/presentation/providers/conversation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set environment to PROD
  EnvironmentConfig.setEnvironment(Environment.prod);

  // Initialize Firebase with PROD-specific options
  await Firebase.initializeApp(
    options: FirebaseOptionsProd.currentPlatform,
  );

  // Initialize dependency injection
  DependencyInjection.initialize();

  runApp(const ViernesApp());
}

class ViernesApp extends StatelessWidget {
  const ViernesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<auth_provider.AuthProvider>(
          create: (context) => DependencyInjection.authProvider,
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DependencyInjection.dashboardProvider,
        ),
        ChangeNotifierProvider<CustomerProvider>(
          create: (context) => DependencyInjection.customerProvider,
        ),
        ChangeNotifierProvider<ConversationProvider>(
          create: (context) => DependencyInjection.conversationProvider,
        ),
      ],
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