import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../../../../shared/widgets/viernes_availability_toggle.dart';
import '../../../../shared/widgets/viernes_settings_tile.dart';
import '../../../auth/presentation/providers/auth_provider.dart' as auth_provider;
import 'appearance_settings_page.dart';
import 'notification_settings_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final themeMode = ref.watch(themeManagerProvider);

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: provider_pkg.Consumer<auth_provider.AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.user;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(isDark),

                    const SizedBox(height: 24),

                    // User Info Card
                    ViernesGlassmorphismCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // User avatar with gradient
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ViernesColors.secondary.withValues(alpha: 0.8),
                                  ViernesColors.accent.withValues(alpha: 0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? ViernesColors.accent.withValues(alpha: 0.3)
                                    : ViernesColors.primary.withValues(alpha: 0.3),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                (user != null && user.email.isNotEmpty)
                                    ? user.email[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // User name
                          Text(
                            user?.fullname ?? user?.displayName ?? 'User',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // User email
                          Text(
                            user?.email ?? 'No email',
                            style: ViernesTextStyles.bodyText.copyWith(
                              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Email verification badge
                          if (user != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: user.emailVerified
                                    ? ViernesColors.success.withValues(alpha: 0.15)
                                    : ViernesColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: user.emailVerified
                                      ? ViernesColors.success
                                      : ViernesColors.warning,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    user.emailVerified ? Icons.verified : Icons.warning_amber,
                                    color: user.emailVerified
                                        ? ViernesColors.success
                                        : ViernesColors.warning,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    user.emailVerified
                                        ? AppStrings.emailVerified
                                        : AppStrings.emailNotVerified,
                                    style: ViernesTextStyles.bodySmall.copyWith(
                                      color: user.emailVerified
                                          ? ViernesColors.success
                                          : ViernesColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Organizational Info (if available)
                          if (user?.organizationalRole != null || user?.organizationalStatus != null) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Role badge
                            if (user?.organizationalRole != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: ViernesColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ViernesColors.primary,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.badge,
                                      color: ViernesColors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      user!.organizationalRole!.description,
                                      style: ViernesTextStyles.bodySmall.copyWith(
                                        color: ViernesColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Availability Toggle Card (only show if user has organizational status)
                    if (user?.organizationalStatus != null)
                      ViernesAvailabilityCard(
                        isAvailable: user!.organizationalStatus!.isActive,
                        isLoading: authProvider.isTogglingAvailability,
                        onToggle: (_) => authProvider.toggleAvailability(),
                        errorMessage: authProvider.errorMessage,
                      ),

                    const SizedBox(height: 16),

                    // Notification Settings Tile
                    ViernesSettingsTile(
                      icon: Icons.notifications_outlined,
                      title: AppStrings.notifications,
                      subtitle: NotificationSettingsPage.getNotificationSummary(),
                      iconColor: ViernesColors.primary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Appearance Settings Tile
                    ViernesSettingsTile(
                      icon: Icons.palette_outlined,
                      title: AppStrings.appearance,
                      subtitle: AppearanceSettingsPage.getThemeSummary(themeMode),
                      iconColor: ViernesColors.secondary,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AppearanceSettingsPage(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign out button
                    Semantics(
                      label: AppStrings.signOutButton,
                      button: true,
                      child: ViernesGradientButton(
                        text: AppStrings.signOut,
                        onPressed: () => _showSignOutDialog(context, authProvider),
                        isLoading: authProvider.status == auth_provider.AuthStatus.loading,
                        height: 56,
                        borderRadius: 14,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Center(
        child: Text(
          AppStrings.profile,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, auth_provider.AuthProvider authProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => provider_pkg.Consumer<auth_provider.AuthProvider>(
        builder: (context, provider, child) => Dialog(
          backgroundColor: Colors.transparent,
          child: ViernesGlassmorphismCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ViernesColors.danger.withValues(alpha: 0.3),
                        ViernesColors.warning.withValues(alpha: 0.3),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 32,
                    color: ViernesColors.danger,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  AppStrings.signOutConfirmTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  AppStrings.signOutConfirmMessage,
                  style: ViernesTextStyles.bodyText.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                                .withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                AppStrings.cancel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ViernesColors.getTextColor(isDark),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ViernesGradientButton(
                        text: AppStrings.confirm,
                        onPressed: provider.status == auth_provider.AuthStatus.loading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                provider.signOut();
                              },
                        isLoading: provider.status == auth_provider.AuthStatus.loading,
                        height: 48,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
