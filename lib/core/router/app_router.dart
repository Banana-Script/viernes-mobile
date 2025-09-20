import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Authentication pages
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/password_recovery_page.dart';

// MVP Core pages
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/conversations/presentation/pages/conversations_page.dart';
import '../../features/conversations/presentation/pages/conversation_chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

// Future Feature pages (placeholder structure)
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/customers/presentation/pages/customer_detail_page.dart';
import '../../features/calls/presentation/pages/calls_page.dart';
import '../../features/voice/presentation/pages/voice_agents_page.dart';
import '../../features/voice/presentation/pages/inbound_calls_page.dart';
import '../../features/voice/presentation/pages/outbound_campaigns_page.dart';
import '../../features/organizations/presentation/pages/organization_settings_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/workflows/presentation/pages/workflows_page.dart';
import '../../features/templates/presentation/pages/templates_page.dart';

// Shared widgets
import '../../shared/widgets/main_layout.dart';
import '../../shared/widgets/splash_screen.dart';
import '../../shared/widgets/error_page.dart';
import '../../shared/widgets/coming_soon_page.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => ErrorPage(error: state.error.toString()),
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final authRoutes = ['/login', '/register', '/auth/recovery'];
      final publicRoutes = ['/splash', ...authRoutes];
      final isOnAuthRoute = authRoutes.contains(state.matchedLocation);
      final isOnPublicRoute = publicRoutes.contains(state.matchedLocation);

      // Allow splash screen and public routes
      if (isOnPublicRoute) return null;

      // If not logged in and not on auth pages, redirect to login
      if (!isLoggedIn && !isOnPublicRoute) {
        return '/login';
      }

      // If logged in and on auth pages, redirect to dashboard
      if (isLoggedIn && isOnAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Splash route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes (public)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/recovery',
        name: 'passwordRecovery',
        builder: (context, state) => const PasswordRecoveryPage(),
      ),

      // Main authenticated app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          // MVP Core Features
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/conversations',
            name: 'conversations',
            builder: (context, state) => const ConversationsPage(),
            routes: [
              GoRoute(
                path: '/:conversationId',
                name: 'conversationChat',
                builder: (context, state) {
                  final conversationId = state.pathParameters['conversationId']!;
                  return ConversationChatPage(conversationId: conversationId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Future Features Routes (outside main shell for different navigation patterns)
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
        routes: [
          GoRoute(
            path: '/:customerId',
            name: 'customerDetail',
            builder: (context, state) {
              final customerId = state.pathParameters['customerId']!;
              return CustomerDetailPage(customerId: customerId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/calls',
        name: 'calls',
        builder: (context, state) => const CallsPage(),
      ),
      GoRoute(
        path: '/voice/agents',
        name: 'voiceAgents',
        builder: (context, state) => const VoiceAgentsPage(),
      ),
      GoRoute(
        path: '/voice/inbound-calls',
        name: 'inboundCalls',
        builder: (context, state) => const InboundCallsPage(),
      ),
      GoRoute(
        path: '/voice/outbound-campaigns',
        name: 'outboundCampaigns',
        builder: (context, state) => const OutboundCampaignsPage(),
      ),
      GoRoute(
        path: '/organization/settings',
        name: 'organizationSettings',
        builder: (context, state) => const OrganizationSettingsPage(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsPage(),
      ),
      GoRoute(
        path: '/workflows',
        name: 'workflows',
        builder: (context, state) => const WorkflowsPage(),
      ),
      GoRoute(
        path: '/templates',
        name: 'templates',
        builder: (context, state) => const TemplatesPage(),
      ),

      // Coming Soon placeholder for future features
      GoRoute(
        path: '/coming-soon/:feature',
        name: 'comingSoon',
        builder: (context, state) {
          final feature = state.pathParameters['feature'] ?? 'Feature';
          return ComingSoonPage(featureName: feature);
        },
      ),
    ],
  );

  static GoRouter get router => _router;

  // Helper method to check if current route is in main navigation
  static bool isMainNavigationRoute(String route) {
    const mainRoutes = ['/dashboard', '/conversations', '/profile'];
    return mainRoutes.contains(route);
  }

  // Helper method to get the current route name
  static String? getCurrentRouteName() {
    final location = _router.routerDelegate.currentConfiguration.uri.toString();
    return location;
  }
}

// Navigation helper methods with type-safe navigation
class AppNavigation {
  static final GoRouter _router = AppRouter.router;

  // Authentication Navigation
  static void goToLogin() => _router.goNamed('login');
  static void goToRegister() => _router.goNamed('register');
  static void goToPasswordRecovery() => _router.goNamed('passwordRecovery');

  // MVP Core Navigation
  static void goToDashboard() => _router.goNamed('dashboard');
  static void goToConversations() => _router.goNamed('conversations');
  static void goToConversationChat(String conversationId) =>
      _router.goNamed('conversationChat', pathParameters: {'conversationId': conversationId});
  static void goToProfile() => _router.goNamed('profile');

  // Future Features Navigation
  static void goToCustomers() => _router.goNamed('customers');
  static void goToCustomerDetail(String customerId) =>
      _router.goNamed('customerDetail', pathParameters: {'customerId': customerId});
  static void goToCalls() => _router.goNamed('calls');
  static void goToVoiceAgents() => _router.goNamed('voiceAgents');
  static void goToInboundCalls() => _router.goNamed('inboundCalls');
  static void goToOutboundCampaigns() => _router.goNamed('outboundCampaigns');
  static void goToOrganizationSettings() => _router.goNamed('organizationSettings');
  static void goToAnalytics() => _router.goNamed('analytics');
  static void goToWorkflows() => _router.goNamed('workflows');
  static void goToTemplates() => _router.goNamed('templates');

  // Utility methods
  static void goToComingSoon(String featureName) =>
      _router.goNamed('comingSoon', pathParameters: {'feature': featureName});

  static void pop() => _router.pop();
  static bool canPop() => _router.canPop();

  static void logout() {
    // Clear any app state here if needed
    _router.goNamed('login');
  }
}

// Route definitions for easy reference
class AppRoutes {
  // Authentication
  static const login = '/login';
  static const register = '/register';
  static const passwordRecovery = '/auth/recovery';

  // MVP Core
  static const dashboard = '/dashboard';
  static const conversations = '/conversations';
  static const profile = '/profile';

  // Future Features
  static const customers = '/customers';
  static const calls = '/calls';
  static const voiceAgents = '/voice/agents';
  static const inboundCalls = '/voice/inbound-calls';
  static const outboundCampaigns = '/voice/outbound-campaigns';
  static const organizationSettings = '/organization/settings';
  static const analytics = '/analytics';
  static const workflows = '/workflows';
  static const templates = '/templates';
}