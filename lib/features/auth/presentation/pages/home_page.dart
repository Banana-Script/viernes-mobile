import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_button.dart';
import '../../../../shared/widgets/viernes_card.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ViernesColors.backgroundDark : ViernesColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Viernes Dashboard',
          style: ViernesTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? ViernesColors.secondary : ViernesColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? ViernesColors.secondary : ViernesColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
                ),
                child: Icon(
                  Icons.logout,
                  color: isDark ? ViernesColors.secondary : ViernesColors.primary,
                ),
              ),
              onPressed: () => _showSignOutDialog(context),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return SafeArea(
            child: SingleChildScrollView(
              padding: ViernesSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ViernesSpacing.spaceXl,

                  // Welcome Header Card
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
                            Icons.dashboard,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        ViernesSpacing.spaceLg,
                        Text(
                          'Welcome to Viernes!',
                          style: ViernesTextStyles.h2.copyWith(
                            color: isDark ? Colors.white : ViernesColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ViernesSpacing.spaceXs,
                        Text(
                          'Your AI-powered business assistant',
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

                  // User Info Card
                  ViernesCard.elevated(
                    title: 'Account Information',
                    child: user != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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

                  // Quick Actions Card
                  ViernesCard.outlined(
                    title: 'Quick Actions',
                    child: Column(
                      children: [
                        Text(
                          'Explore Viernes features and manage your business with AI assistance.',
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
                                icon: const Icon(Icons.settings, size: 18),
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
                                icon: const Icon(Icons.help, size: 18),
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
                    isLoading: authProvider.status == AuthStatus.loading,
                    onPressed: () => _showSignOutDialog(context),
                    icon: const Icon(Icons.logout, size: 20),
                  ),

                  ViernesSpacing.spaceLg,
                ],
              ),
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
                context.read<AuthProvider>().signOut();
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