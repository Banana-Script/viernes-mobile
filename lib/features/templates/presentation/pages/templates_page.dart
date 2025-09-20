import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../voice/presentation/pages/voice_agents_page.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Templates',
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
        title: 'Message Templates',
        subtitle: 'Pre-built Communication Templates',
        description: 'Create, manage, and use pre-built templates for messages, emails, voice scripts, and automated responses to ensure consistent communication.',
        features: [
          'Message and email templates',
          'Voice script templates',
          'Automated response templates',
          'Template categories and tags',
          'Template performance analytics',
        ],
      ),
    );
  }
}