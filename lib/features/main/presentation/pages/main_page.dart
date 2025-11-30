import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../customers/presentation/pages/customer_list_page.dart';
import '../../../conversations/presentation/pages/conversations_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const CustomerListPage(),
    const ConversationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get agent status for LED indicators (using select for optimized rebuilds)
    final hasStatus = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus != null,
    );
    final isActive = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus?.isActive ?? false,
    );

    // LED color based on status
    final ledColor = hasStatus
        ? (isActive ? ViernesColors.success : ViernesColors.danger)
        : Colors.transparent;

    return Scaffold(
      body: Row(
        children: [
          // Left LED bar
          if (hasStatus)
            _LedBar(color: ledColor, isLeft: true),
          // Main content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
          // Right LED bar
          if (hasStatus)
            _LedBar(color: ledColor, isLeft: false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark
            ? ViernesColors.backgroundDark
            : ViernesColors.backgroundLight,
        selectedItemColor: ViernesColors.getThemePrimary(isDark),
        unselectedItemColor: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
        selectedLabelStyle: ViernesTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: ViernesTextStyles.caption,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.people : Icons.people_outline,
            ),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.chat : Icons.chat_outlined,
            ),
            label: 'Conversations',
          ),
          BottomNavigationBarItem(
            icon: _ProfileIconWithBadge(isSelected: _currentIndex == 3),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Profile icon widget for bottom navigation
class _ProfileIconWithBadge extends StatelessWidget {
  final bool isSelected;

  const _ProfileIconWithBadge({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // Simple icon without badge - status now shown via LED edge indicators
    return Icon(
      isSelected ? Icons.person : Icons.person_outline,
    );
  }
}

/// LED bar indicator for agent status
class _LedBar extends StatelessWidget {
  final Color color;
  final bool isLeft;

  const _LedBar({required this.color, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.7),
        boxShadow: [
          // Inner glow (toward content)
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(isLeft ? 3 : -3, 0),
          ),
          // Softer outer glow
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(isLeft ? 6 : -6, 0),
          ),
        ],
      ),
    );
  }
}
