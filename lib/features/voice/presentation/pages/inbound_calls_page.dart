import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import 'voice_agents_page.dart';

class InboundCallsPage extends StatelessWidget {
  const InboundCallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Inbound Calls',
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
        title: 'Inbound Calls',
        subtitle: 'Smart Call Management',
        description: 'Manage and analyze all incoming calls with AI-powered insights, automatic routing, and real-time monitoring.',
        features: [
          'Real-time call monitoring',
          'Automatic call routing',
          'Call recording and transcription',
          'Caller sentiment analysis',
          'Performance metrics and reports',
        ],
      ),
    );
  }
}