import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/animated_status_badge.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../customers/presentation/pages/customer_list_page.dart';
import '../../../conversations/presentation/pages/conversations_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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

/// Optimized profile icon widget that only rebuilds when agent status changes
class _ProfileIconWithBadge extends StatelessWidget {
  final bool isSelected;

  const _ProfileIconWithBadge({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    // Only rebuilds when isActive or hasStatus changes
    final isActive = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus?.isActive ?? false,
    );

    final hasStatus = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus != null,
    );

    final icon = Icon(
      isSelected ? Icons.person : Icons.person_outline,
    );

    return hasStatus
        ? AnimatedStatusBadge(
            isActive: isActive,
            child: icon,
          )
        : icon;
  }
}
