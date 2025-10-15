import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_card.dart';
import '../../../../shared/widgets/viernes_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart' as auth_provider;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: ViernesTextStyles.h3.copyWith(
            color: ViernesColors.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ViernesColors.getControlBackground(isDark),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<auth_provider.AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return SingleChildScrollView(
            padding: ViernesSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ViernesSpacing.spaceXl,

                // Profile Header Card
                ViernesCard.filled(
                  backgroundColor: isDark
                      ? ViernesColors.secondary.withValues(alpha: 0.1)
                      : ViernesColors.primary.withValues(alpha: 0.05),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: ViernesColors.viernesGradient,
                          borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      ViernesSpacing.spaceLg,
                      Text(
                        user?.displayName ?? 'User',
                        style: ViernesTextStyles.h2.copyWith(
                          color: isDark ? Colors.white : ViernesColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ViernesSpacing.spaceXs,
                      Text(
                        user?.email ?? '',
                        style: ViernesTextStyles.bodyLarge.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : ViernesColors.primary.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                ViernesSpacing.spaceXxl,

                // Account Information Card
                ViernesCard.elevated(
                  child: user != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Information',
                              style: ViernesTextStyles.h5.copyWith(
                                color: isDark ? Colors.white : ViernesColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ViernesSpacing.spaceMd,
                            _InfoRow(
                              label: 'Email',
                              value: user.email,
                              icon: Icons.email,
                            ),
                            ViernesSpacing.spaceMd,

                            if (user.displayName != null) ...[
                              _InfoRow(
                                label: 'Name',
                                value: user.displayName!,
                                icon: Icons.person,
                              ),
                              ViernesSpacing.spaceMd,
                            ],

                            _InfoRow(
                              label: 'User ID',
                              value: user.uid,
                              icon: Icons.fingerprint,
                            ),
                            ViernesSpacing.spaceMd,

                            // Email Verification Status
                            Container(
                              padding: ViernesSpacing.all(ViernesSpacing.sm),
                              decoration: BoxDecoration(
                                color: user.emailVerified
                                    ? ViernesColors.success.withValues(alpha: 0.1)
                                    : ViernesColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                                border: Border.all(
                                  color: user.emailVerified
                                      ? ViernesColors.success
                                      : ViernesColors.warning,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    user.emailVerified ? Icons.verified : Icons.warning,
                                    color: user.emailVerified
                                        ? ViernesColors.success
                                        : ViernesColors.warning,
                                    size: 20,
                                  ),
                                  ViernesSpacing.hSpaceSm,
                                  Text(
                                    user.emailVerified
                                        ? 'Email Verified'
                                        : 'Email Not Verified',
                                    style: ViernesTextStyles.bodyText.copyWith(
                                      color: user.emailVerified
                                          ? ViernesColors.success
                                          : ViernesColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),

                ViernesSpacing.spaceXxl,

                // Actions Card
                ViernesCard.outlined(
                  child: Column(
                    children: [
                      Text(
                        'Settings',
                        style: ViernesTextStyles.h5.copyWith(
                          color: isDark ? Colors.white : ViernesColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ViernesSpacing.spaceSm,
                      Text(
                        'Manage your account settings and preferences.',
                        style: ViernesTextStyles.bodyText.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : ViernesColors.primary.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ViernesSpacing.spaceLg,

                      Row(
                        children: [
                          Expanded(
                            child: ViernesButton.secondary(
                              text: 'Settings',
                              icon: Icons.settings,
                              size: ViernesButtonSize.small,
                              onPressed: () {
                                // TODO: Navigate to settings
                              },
                            ),
                          ),
                          ViernesSpacing.hSpaceMd,
                          Expanded(
                            child: ViernesButton.text(
                              text: 'Help',
                              icon: Icons.help,
                              size: ViernesButtonSize.small,
                              onPressed: () {
                                // TODO: Navigate to help
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                ViernesSpacing.spaceXxl,

                // Sign out button
                ViernesButton.danger(
                  text: 'Sign Out',
                  isLoading: authProvider.status == auth_provider.AuthStatus.loading,
                  onPressed: () => _showSignOutDialog(context),
                  icon: Icons.logout,
                ),

                ViernesSpacing.spaceLg,
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<auth_provider.AuthProvider>().signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: ViernesSpacing.all(ViernesSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? ViernesColors.primary.withValues(alpha: 0.05)
            : ViernesColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? ViernesColors.secondary : ViernesColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ViernesSpacing.radiusSm),
              ),
              child: Icon(
                icon!,
                size: 16,
                color: isDark ? ViernesColors.secondary : ViernesColors.primary,
              ),
            ),
            ViernesSpacing.hSpaceSm,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : ViernesColors.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ViernesSpacing.spaceXs,
                Text(
                  value,
                  style: ViernesTextStyles.bodyText.copyWith(
                    color: isDark ? Colors.white : ViernesColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}