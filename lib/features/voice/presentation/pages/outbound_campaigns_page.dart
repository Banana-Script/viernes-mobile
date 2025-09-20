import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import 'voice_agents_page.dart';

class OutboundCampaignsPage extends StatelessWidget {
  const OutboundCampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Outbound Campaigns',
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
        title: 'Outbound Campaigns',
        subtitle: 'Automated Marketing Calls',
        description: 'Create and manage automated outbound calling campaigns with AI voice agents for marketing, surveys, and customer outreach.',
        features: [
          'Campaign creation and scheduling',
          'Contact list management',
          'AI-powered call scripts',
          'Real-time campaign monitoring',
          'Detailed analytics and reporting',
        ],
      ),
    );
  }
}