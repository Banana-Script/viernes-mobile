import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Authentication pages
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/password_recovery_page.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';

// Shared widgets
import '../../shared/widgets/coming_soon_page.dart';
import '../../shared/widgets/splash_screen.dart';
import '../../shared/widgets/error_page.dart';
import '../../shared/widgets/main_layout.dart';

/// Custom refresh listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Custom refresh notifier for GoRouter that listens to authentication state changes
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this.ref) {
    ref.listen(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref ref;
}

/// Route names for navigation
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String passwordRecovery = '/password-recovery';

  // Main app routes
  static const String dashboard = '/dashboard';
  static const String conversations = '/conversations';
  static const String conversationChat = '/conversations/:id';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Additional feature routes
  static const String analytics = '/analytics';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String templates = '/templates';
  static const String workflows = '/workflows';
  static const String calls = '/calls';
  static const String voiceAgents = '/voice-agents';
  static const String organization = '/organization';
}

/// Router configuration using GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RouteNames.splash,
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isInitialized = ref.read(authNotifierProvider).isInitialized;
      final currentLocation = state.uri.path;

      // Don't redirect if not initialized yet
      if (!isInitialized) return null;

      // Public routes that don't require authentication
      final publicRoutes = [
        RouteNames.splash,
        RouteNames.login,
        RouteNames.passwordRecovery,
      ];

      final isPublicRoute = publicRoutes.contains(currentLocation);

      // If user is authenticated and trying to access public route, redirect to dashboard
      if (isAuthenticated && isPublicRoute && currentLocation != RouteNames.splash) {
        return RouteNames.dashboard;
      }

      // If user is not authenticated and trying to access private route, redirect to login
      if (!isAuthenticated && !isPublicRoute) {
        return RouteNames.login;
      }

      // No redirect needed
      return null;
    },
    refreshListenable: GoRouterRefreshNotifier(ref),
    routes: [
      // Splash route
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.passwordRecovery,
        name: RouteNames.passwordRecovery,
        builder: (context, state) => const PasswordRecoveryPage(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: RouteNames.dashboard,
            name: RouteNames.dashboard,
            builder: (context, state) => const ComingSoonPage(title: 'Dashboard'),
          ),

          // Conversations
          GoRoute(
            path: RouteNames.conversations,
            name: RouteNames.conversations,
            builder: (context, state) => const ComingSoonPage(title: 'Conversations'),
            routes: [
              // Individual conversation chat
              GoRoute(
                path: '/:id',
                name: RouteNames.conversationChat,
                builder: (context, state) {
                  final conversationId = state.pathParameters['id'] ?? '';
                  return ComingSoonPage(title: 'Chat: $conversationId');
                },
              ),
            ],
          ),

          // Profile
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ComingSoonPage(title: 'Profile'),
          ),

          // Settings
          GoRoute(
            path: RouteNames.settings,
            name: RouteNames.settings,
            builder: (context, state) => const ComingSoonPage(title: 'Settings'),
          ),
        ],
      ),

      // Additional feature routes (outside main shell)
      GoRoute(
        path: RouteNames.analytics,
        name: RouteNames.analytics,
        builder: (context, state) => const ComingSoonPage(title: 'Analytics'),
      ),
      GoRoute(
        path: RouteNames.customers,
        name: RouteNames.customers,
        builder: (context, state) => const ComingSoonPage(title: 'Customers'),
        routes: [
          GoRoute(
            path: '/:id',
            name: RouteNames.customerDetail,
            builder: (context, state) {
              final customerId = state.pathParameters['id'] ?? '';
              return ComingSoonPage(title: 'Customer: $customerId');
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.templates,
        name: RouteNames.templates,
        builder: (context, state) => const ComingSoonPage(title: 'Templates'),
      ),
      GoRoute(
        path: RouteNames.workflows,
        name: RouteNames.workflows,
        builder: (context, state) => const ComingSoonPage(title: 'Workflows'),
      ),
      GoRoute(
        path: RouteNames.calls,
        name: RouteNames.calls,
        builder: (context, state) => const ComingSoonPage(title: 'Calls'),
      ),
      GoRoute(
        path: RouteNames.voiceAgents,
        name: RouteNames.voiceAgents,
        builder: (context, state) => const ComingSoonPage(title: 'Voice Agents'),
      ),
      GoRoute(
        path: RouteNames.organization,
        name: RouteNames.organization,
        builder: (context, state) => const ComingSoonPage(title: 'Organization'),
      ),
    ],
  );
});

/// Navigation helper class
class AppNavigation {
  AppNavigation._();

  /// Navigate to login
  static void toLogin(BuildContext context) {
    context.goNamed(RouteNames.login);
  }

  /// Navigate to dashboard
  static void toDashboard(BuildContext context) {
    context.goNamed(RouteNames.dashboard);
  }

  /// Navigate to conversations
  static void toConversations(BuildContext context) {
    context.goNamed(RouteNames.conversations);
  }

  /// Navigate to specific conversation
  static void toConversationChat(BuildContext context, String conversationId) {
    context.goNamed(
      RouteNames.conversationChat,
      pathParameters: {'id': conversationId},
    );
  }

  /// Navigate to profile
  static void toProfile(BuildContext context) {
    context.goNamed(RouteNames.profile);
  }

  /// Navigate to settings
  static void toSettings(BuildContext context) {
    context.goNamed(RouteNames.settings);
  }

  /// Navigate to analytics
  static void toAnalytics(BuildContext context) {
    context.goNamed(RouteNames.analytics);
  }

  /// Navigate to customers
  static void toCustomers(BuildContext context) {
    context.goNamed(RouteNames.customers);
  }

  /// Navigate to specific customer
  static void toCustomerDetail(BuildContext context, String customerId) {
    context.goNamed(
      RouteNames.customerDetail,
      pathParameters: {'id': customerId},
    );
  }

  /// Navigate back
  static void back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  /// Replace current route
  static void replace(BuildContext context, String location) {
    context.go(location);
  }

  /// Push new route
  static void push(BuildContext context, String location) {
    context.push(location);
  }
}