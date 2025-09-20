import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../voice/presentation/pages/voice_agents_page.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.analytics,
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
        title: 'Analytics Dashboard',
        subtitle: 'Business Intelligence',
        description: 'Comprehensive analytics and reporting for all your business communications, voice interactions, and customer engagement metrics.',
        features: [
          'Real-time performance metrics',
          'Conversation analytics',
          'Voice interaction insights',
          'Customer engagement reports',
          'Custom dashboard creation',
        ],
      ),
    );
  }
}