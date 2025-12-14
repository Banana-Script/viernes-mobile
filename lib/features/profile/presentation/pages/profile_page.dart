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
import '../../../auth/presentation/providers/auth_provider.dart' as auth_provider;
import '../widgets/notification_settings.dart';

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

                    // Notification Settings
                    const NotificationSettings(),

                    const SizedBox(height: 16),

                    // Settings Card
                    ViernesGlassmorphismCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.settings,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Theme selector
                          _buildThemeSelector(context, ref, isDark, themeMode),
                        ],
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

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, bool isDark, ThemeMode currentTheme) {
    return Column(
      children: [
        // Light mode option
        _buildThemeOption(
          context: context,
          ref: ref,
          isDark: isDark,
          themeMode: ThemeMode.light,
          currentTheme: currentTheme,
          icon: Icons.light_mode,
          title: AppStrings.lightMode,
          description: AppStrings.lightModeDesc,
        ),
        const SizedBox(height: 12),

        // Dark mode option
        _buildThemeOption(
          context: context,
          ref: ref,
          isDark: isDark,
          themeMode: ThemeMode.dark,
          currentTheme: currentTheme,
          icon: Icons.dark_mode,
          title: AppStrings.darkMode,
          description: AppStrings.darkModeDesc,
        ),
        const SizedBox(height: 12),

        // System mode option
        _buildThemeOption(
          context: context,
          ref: ref,
          isDark: isDark,
          themeMode: ThemeMode.system,
          currentTheme: currentTheme,
          icon: Icons.brightness_auto,
          title: AppStrings.autoMode,
          description: AppStrings.autoModeDesc,
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required ThemeMode themeMode,
    required ThemeMode currentTheme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = currentTheme == themeMode;

    return Semantics(
      label: '${AppStrings.themeSelectorPrefix}$title',
      value: isSelected ? AppStrings.selected : AppStrings.notSelected,
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? ViernesColors.accent : ViernesColors.secondary).withValues(alpha: 0.15)
              : (isDark ? ViernesColors.accent : ViernesColors.primary).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? ViernesColors.accent : ViernesColors.secondary)
                : (isDark ? ViernesColors.accent : ViernesColors.primary).withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              try {
                final themeManager = ref.read(themeManagerProvider.notifier);
                await themeManager.setThemeMode(themeMode);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${AppStrings.themeChangeError}: $e'),
                      backgroundColor: ViernesColors.danger,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              ViernesColors.secondary.withValues(alpha: 0.6),
                              ViernesColors.accent.withValues(alpha: 0.6),
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? ViernesColors.accent : ViernesColors.primary)
                            .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.black
                        : (isDark ? ViernesColors.accent : ViernesColors.primary),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ViernesTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ViernesColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: ViernesTextStyles.bodySmall.copyWith(
                          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ViernesColors.secondary.withValues(alpha: 0.8),
                          ViernesColors.accent.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
