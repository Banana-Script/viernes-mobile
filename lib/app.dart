import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'core/constants/app_constants.dart';
import 'core/di/dependency_injection.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart' as auth_provider;
import 'features/auth/presentation/pages/login_page.dart';
import 'features/main/presentation/pages/main_page.dart';
import 'features/splash/presentation/pages/splash_screen.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/customers/presentation/providers/customer_provider.dart';
import 'features/conversations/presentation/providers/conversation_provider.dart';

/// Initializes common app services.
/// Call this from main_dev.dart or main_prod.dart after:
/// 1. WidgetsFlutterBinding.ensureInitialized()
/// 2. Firebase initialization
/// Returns SharedPreferences instance for ProviderScope override.
Future<SharedPreferences> initializeApp() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  DependencyInjection.initialize();
  await NotificationService.instance.initialize(sharedPreferences);
  return sharedPreferences;
}

/// Root application widget.
/// Uses Riverpod for theme management and Provider for feature providers.
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

/// Authentication wrapper that handles SSE connection based on auth state.
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _sseInitialized = false;
  bool _showSplash = true;

  void _onSplashComplete() {
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show animated splash screen first
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    return provider.Consumer<auth_provider.AuthProvider>(
      builder: (context, authProvider, child) {
        debugPrint('[AuthWrapper] Status: ${authProvider.status}, sseInit: $_sseInitialized, user: ${authProvider.user?.email}');

        // Show loading screen while checking authentication state
        if (authProvider.status == auth_provider.AuthStatus.initial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Connect SSE and notifications when authenticated
        if (authProvider.status == auth_provider.AuthStatus.authenticated &&
            !_sseInitialized) {
          // Set flag immediately to prevent multiple callbacks being scheduled
          _sseInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              try {
                _initializeRealTimeServices(context, authProvider);
              } catch (e) {
                _sseInitialized = false; // Reset on failure
                debugPrint('[AuthWrapper] Error initializing real-time services: $e');
              }
            }
          });
        }

        // Disconnect when unauthenticated (use postFrameCallback to avoid setState during build)
        if (authProvider.status == auth_provider.AuthStatus.unauthenticated &&
            _sseInitialized) {
          _sseInitialized = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _cleanupRealTimeServices(context);
            }
          });
        }

        // Navigate based on authentication status
        switch (authProvider.status) {
          case auth_provider.AuthStatus.authenticated:
            return const MainPage();
          case auth_provider.AuthStatus.unauthenticated:
          case auth_provider.AuthStatus.error:
            return const LoginPage();
          case auth_provider.AuthStatus.loading:
            return authProvider.user != null ? const MainPage() : const LoginPage();
          default:
            return const LoginPage();
        }
      },
    );
  }

  void _initializeRealTimeServices(
    BuildContext context,
    auth_provider.AuthProvider authProvider,
  ) {
    final user = authProvider.user;
    if (user == null) {
      debugPrint('[SSE Init] User is null, skipping SSE connection');
      return;
    }

    final organizationId = user.organizationId;
    final userId = user.databaseId;

    debugPrint('[SSE Init] User: ${user.email}, orgId: $organizationId, userId: $userId');

    if (organizationId == null || userId == null) {
      debugPrint('[SSE Init] Missing orgId or userId, skipping SSE connection');
      return;
    }

    debugPrint('[SSE Init] Connecting SSE for org $organizationId, user $userId');

    // Connect SSE in ConversationProvider
    final conversationProvider = provider.Provider.of<ConversationProvider>(
      context,
      listen: false,
    );
    conversationProvider.setCurrentUserAgentId(userId);
    conversationProvider.connectSSE(
      organizationId: organizationId,
      currentUserId: userId,
    );

    // Set current user ID for notification filtering and start listening
    NotificationService.instance.setCurrentUserId(userId);
    NotificationService.instance.startListening();

    debugPrint('[SSE Init] SSE initialization complete');
  }

  void _cleanupRealTimeServices(BuildContext context) {
    debugPrint('[SSE Cleanup] Disconnecting SSE...');

    // Disconnect SSE
    final conversationProvider = provider.Provider.of<ConversationProvider>(
      context,
      listen: false,
    );
    conversationProvider.disconnectSSE();

    // Stop notification listening and clear user ID
    NotificationService.instance.stopListening();
    NotificationService.instance.setCurrentUserId(null);

    debugPrint('[SSE Cleanup] SSE disconnected');
  }

  @override
  void dispose() {
    // Ensure cleanup if widget disposed while authenticated
    if (_sseInitialized) {
      try {
        DependencyInjection.conversationProvider.disconnectSSE();
        NotificationService.instance.stopListening();
        debugPrint('[AuthWrapper] Cleaned up SSE on dispose');
      } catch (e) {
        debugPrint('[AuthWrapper] Error during dispose cleanup: $e');
      }
    }
    super.dispose();
  }
}
