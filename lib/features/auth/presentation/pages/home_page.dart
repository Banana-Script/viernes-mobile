import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../shared/widgets/viernes_button.dart';
import '../../../../shared/widgets/viernes_card.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../demo/presentation/pages/components_demo_page.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? ViernesColors.backgroundDark : ViernesColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          l10n.viernesDashboard,
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
      body: provider.Consumer<AuthProvider>(
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
                  ViernesCard.basic(
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
                          l10n.welcomeToViernes,
                          style: ViernesTextStyles.h2.copyWith(
                            color: isDark ? Colors.white : ViernesColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ViernesSpacing.spaceXs,
                        Text(
                          l10n.aiBusinessAssistant,
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
                    child: user != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                label: l10n.email,
                                value: user.email,
                                icon: Icons.email,
                              ),
                              ViernesSpacing.spaceMd,

                              if (user.displayName != null) ...[
                                _InfoRow(
                                  label: l10n.name,
                                  value: user.displayName!,
                                  icon: Icons.person,
                                ),
                                ViernesSpacing.spaceMd,
                              ],

                              _InfoRow(
                                label: l10n.userId,
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
                                          ? l10n.emailVerified
                                          : l10n.emailNotVerified,
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
                    child: Column(
                      children: [
                        Text(
                          l10n.exploreViernes,
                          style: ViernesTextStyles.bodyText.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : ViernesColors.primary.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ViernesSpacing.spaceLg,

                        // Components Demo Action
                        ViernesButton.primary(
                          text: l10n.viewComponentsDemo,
                          icon: Icons.widgets,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ComponentsDemoPage(),
                              ),
                            );
                          },
                        ),
                        ViernesSpacing.spaceMd,

                        // Dashboard Action
                        ViernesButton.secondary(
                          text: l10n.analyticsDashboard,
                          icon: Icons.analytics,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DashboardPage(),
                              ),
                            );
                          },
                        ),
                        ViernesSpacing.spaceMd,

                        Row(
                          children: [
                            Expanded(
                              child: ViernesButton.secondary(
                                text: l10n.settings,
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
                                text: l10n.help,
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
                    text: l10n.signOut,
                    isLoading: authProvider.status == AuthStatus.loading,
                    onPressed: () => _showSignOutDialog(context),
                    icon: Icons.logout,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.signOutConfirmTitle),
          content: Text(l10n.signOutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                provider.Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              child: Text(l10n.signOut),
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