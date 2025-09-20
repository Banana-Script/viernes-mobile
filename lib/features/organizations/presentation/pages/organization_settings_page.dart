import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../voice/presentation/pages/voice_agents_page.dart';

class OrganizationSettingsPage extends StatelessWidget {
  const OrganizationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.organizationSettings,
          style: AppTheme.headingBold.copyWith(
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNavigation.pop(),
        ),
      ),
      body: const ComingSoonContent(
        title: 'Organization Settings',
        subtitle: 'Manage Your Organization',
        description: 'Complete organization management including user roles, permissions, billing, integrations, and advanced settings.',
        features: [
          'User management and roles',
          'Permission control',
          'Billing and subscriptions',
          'Third-party integrations',
          'Organization branding',
        ],
      ),
    );
  }
}