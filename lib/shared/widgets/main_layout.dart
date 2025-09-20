import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(child: child),
      bottomNavigationBar: const _ViernesBottomNavigationBar(),
      drawer: const _ViernesNavigationDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final location = GoRouterState.of(context).uri.toString();

    // Get page title based on current route
    String getPageTitle() {
      switch (location) {
        case '/dashboard':
          return AppLocalizations.of(context)!.dashboard;
        case '/conversations':
          return AppLocalizations.of(context)!.conversations;
        case '/profile':
          return AppLocalizations.of(context)!.profile;
        default:
          return 'Viernes';
      }
    }

    return AppBar(
      title: Text(
        getPageTitle(),
        style: AppTheme.headingBold.copyWith(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      actions: [
        // Profile Avatar and Menu
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'profile':
                AppNavigation.goToProfile();
                break;
              case 'settings':
                AppNavigation.goToComingSoon('Settings');
                break;
              case 'logout':
                _showLogoutDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.profile),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  const Icon(Icons.settings_outlined),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.settings),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout_outlined, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.logout,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.viernesGray,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ??
                          user?.email?.substring(0, 1).toUpperCase() ??
                          'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              AppNavigation.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
  }
}

// Enhanced Bottom Navigation with Viernes Branding and MVP Focus
class _ViernesBottomNavigationBar extends StatelessWidget {
  const _ViernesBottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    int getCurrentIndex() {
      // Only MVP routes in bottom navigation
      if (currentLocation.startsWith('/dashboard')) return 0;
      if (currentLocation.startsWith('/conversations')) return 1;
      if (currentLocation.startsWith('/profile')) return 2;
      return 0; // Default to dashboard
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha:0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.viernesGray.withValues(alpha:0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: getCurrentIndex(),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              AppNavigation.goToDashboard();
              break;
            case 1:
              AppNavigation.goToConversations();
              break;
            case 2:
              AppNavigation.goToProfile();
              break;
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppTheme.viernesYellow.withValues(alpha:0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: l10n.conversations,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

// Navigation Drawer for Future Features Access
class _ViernesNavigationDrawer extends StatelessWidget {
  const _ViernesNavigationDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // Header with Viernes branding
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.viernesGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withValues(alpha:0.2),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                              user?.displayName?.substring(0, 1).toUpperCase() ??
                                  user?.email?.substring(0, 1).toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? user?.email ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // MVP Core Features (always accessible)
                _DrawerSection(
                  title: l10n.coreFeatures,
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      title: l10n.dashboard,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToDashboard();
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline,
                      title: l10n.conversations,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToConversations();
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.person_outline,
                      title: l10n.profile,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToProfile();
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Future Features
                _DrawerSection(
                  title: l10n.businessTools,
                  children: [
                    _DrawerItem(
                      icon: Icons.people_outline,
                      title: l10n.customers,
                      subtitle: l10n.comingSoon,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToComingSoon('Customers');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.phone_outlined,
                      title: l10n.calls,
                      subtitle: l10n.comingSoon,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToComingSoon('Calls');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.mic_outlined,
                      title: l10n.voiceAgents,
                      subtitle: l10n.comingSoon,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToComingSoon('Voice Agents');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.analytics_outlined,
                      title: l10n.analytics,
                      subtitle: l10n.comingSoon,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToComingSoon('Analytics');
                      },
                    ),
                  ],
                ),

                const Divider(),

                // Organization & Settings
                _DrawerSection(
                  title: l10n.organization,
                  children: [
                    _DrawerItem(
                      icon: Icons.business_outlined,
                      title: l10n.organizationSettings,
                      subtitle: l10n.comingSoon,
                      onTap: () {
                        Navigator.pop(context);
                        AppNavigation.goToComingSoon('Organization Settings');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom section with logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha:0.2),
                ),
              ),
            ),
            child: _DrawerItem(
              icon: Icons.logout_outlined,
              title: l10n.logout,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                AppNavigation.logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widgets for drawer
class _DrawerSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DrawerSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.viernesGray,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.viernesYellow,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      visualDensity: VisualDensity.comfortable,
    );
  }
}