import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_theme_toggle.dart';
import '../../../../shared/widgets/viernes_button.dart';
import '../../../../shared/widgets/viernes_card.dart';

/// Demo page to showcase all Viernes components
/// Perfect for development and testing
class ComponentsDemoPage extends ConsumerWidget {
  const ComponentsDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viernes Components'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: ViernesSpacing.md),
            child: ViernesThemeToggle(
              showLabel: false,
              size: 40,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ViernesSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, '🎨 Theme Controls'),
            _buildThemeSection(context),

            const SizedBox(height: ViernesSpacing.xl),
            _buildSectionHeader(context, '🔘 Buttons'),
            _buildButtonsSection(context),

            const SizedBox(height: ViernesSpacing.xl),
            _buildSectionHeader(context, '📊 Cards'),
            _buildCardsSection(context),

            const SizedBox(height: ViernesSpacing.xl),
            _buildSectionHeader(context, '📈 Metric Cards'),
            _buildMetricCardsSection(context),

            const SizedBox(height: ViernesSpacing.xl),
            _buildSectionHeader(context, '💬 Conversation Cards'),
            _buildConversationCardsSection(context),

            const SizedBox(height: ViernesSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ViernesSpacing.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    return const Column(
      children: [
        ViernesCard.outlined(
          child: Column(
            children: [
              ViernesThemeToggle(showLabel: true),
              SizedBox(height: ViernesSpacing.md),
              ViernesThemeSelector(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection(BuildContext context) {
    return Column(
      children: [
        // Primary buttons row
        Row(
          children: [
            Expanded(
              child: ViernesButton.primary(
                text: 'Primary',
                onPressed: () => _showSnackBar(context, 'Primary button pressed'),
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesButton.primary(
                text: 'Gradient',
                hasGradient: true,
                onPressed: () => _showSnackBar(context, 'Gradient button pressed'),
              ),
            ),
          ],
        ),

        const SizedBox(height: ViernesSpacing.sm),

        // Secondary buttons row
        Row(
          children: [
            Expanded(
              child: ViernesButton.secondary(
                text: 'Secondary',
                onPressed: () => _showSnackBar(context, 'Secondary button pressed'),
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesButton.accent(
                text: 'Accent',
                onPressed: () => _showSnackBar(context, 'Accent button pressed'),
              ),
            ),
          ],
        ),

        const SizedBox(height: ViernesSpacing.sm),

        // Outlined and Text buttons row
        Row(
          children: [
            Expanded(
              child: ViernesButton.outline(
                text: 'Outline',
                onPressed: () => _showSnackBar(context, 'Outline button pressed'),
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesButton.text(
                text: 'Text',
                onPressed: () => _showSnackBar(context, 'Text button pressed'),
              ),
            ),
          ],
        ),

        const SizedBox(height: ViernesSpacing.sm),

        // Status buttons row
        Row(
          children: [
            Expanded(
              child: ViernesButton.success(
                text: 'Success',
                icon: Icons.check,
                onPressed: () => _showSnackBar(context, 'Success button pressed'),
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesButton.danger(
                text: 'Danger',
                icon: Icons.warning,
                onPressed: () => _showSnackBar(context, 'Danger button pressed'),
              ),
            ),
          ],
        ),

        const SizedBox(height: ViernesSpacing.sm),

        // Size variations
        Row(
          children: [
            Expanded(
              child: ViernesButton.primary(
                text: 'Small',
                size: ViernesButtonSize.small,
                onPressed: () => _showSnackBar(context, 'Small button pressed'),
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesButton.primary(
                text: 'Medium',
                size: ViernesButtonSize.medium,
                onPressed: () => _showSnackBar(context, 'Medium button pressed'),
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesButton.primary(
                text: 'Large',
                size: ViernesButtonSize.large,
                onPressed: () => _showSnackBar(context, 'Large button pressed'),
              ),
            ),
          ],
        ),

        const SizedBox(height: ViernesSpacing.sm),

        // Loading button
        const ViernesButton.primary(
          text: 'Loading',
          isLoading: true,
          isFullWidth: true,
          onPressed: null,
        ),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ViernesCard.basic(
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 32),
                    SizedBox(height: ViernesSpacing.sm),
                    Text('Basic Card'),
                  ],
                ),
              ),
            ),
            SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesCard.elevated(
                child: Column(
                  children: [
                    Icon(Icons.layers, size: 32),
                    SizedBox(height: ViernesSpacing.sm),
                    Text('Elevated Card'),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: ViernesSpacing.sm),

        Row(
          children: [
            Expanded(
              child: ViernesCard.outlined(
                child: Column(
                  children: [
                    Icon(Icons.crop_free, size: 32),
                    SizedBox(height: ViernesSpacing.sm),
                    Text('Outlined Card'),
                  ],
                ),
              ),
            ),
            SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesCard.glass(
                child: Column(
                  children: [
                    Icon(Icons.blur_on, size: 32),
                    SizedBox(height: ViernesSpacing.sm),
                    Text('Glass Card'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCardsSection(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ViernesMetricCard(
                title: 'Total Users',
                value: '12.4K',
                subtitle: 'Active users',
                icon: Icons.people,
                trend: '+12%',
                isPositiveTrend: true,
              ),
            ),
            SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesMetricCard(
                title: 'Revenue',
                value: '\$89.2K',
                subtitle: 'This month',
                icon: Icons.attach_money,
                trend: '+8.3%',
                isPositiveTrend: true,
              ),
            ),
          ],
        ),

        SizedBox(height: ViernesSpacing.sm),

        Row(
          children: [
            Expanded(
              child: ViernesMetricCard(
                title: 'Conversion',
                value: '3.2%',
                subtitle: 'Last 7 days',
                icon: Icons.trending_up,
                trend: '-2.1%',
                isPositiveTrend: false,
              ),
            ),
            SizedBox(width: ViernesSpacing.sm),
            Expanded(
              child: ViernesMetricCard(
                title: 'Sessions',
                value: '24.1K',
                subtitle: 'Today',
                icon: Icons.schedule,
                trend: '+15.2%',
                isPositiveTrend: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConversationCardsSection(BuildContext context) {
    return Column(
      children: [
        ViernesConversationCard(
          title: 'John Doe',
          lastMessage: 'Hey! How are you doing today?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isOnline: true,
          unreadCount: 3,
          onTap: () => _showSnackBar(context, 'Tapped on John Doe conversation'),
        ),

        const SizedBox(height: ViernesSpacing.xs),

        ViernesConversationCard(
          title: 'Sarah Wilson',
          lastMessage: 'Thanks for the help with the project!',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isOnline: false,
          unreadCount: 0,
          onTap: () => _showSnackBar(context, 'Tapped on Sarah Wilson conversation'),
        ),

        const SizedBox(height: ViernesSpacing.xs),

        ViernesConversationCard(
          title: 'Team Discussion',
          lastMessage: 'Let\'s schedule a meeting for tomorrow',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          isOnline: false,
          unreadCount: 12,
          onTap: () => _showSnackBar(context, 'Tapped on Team Discussion'),
        ),

        const SizedBox(height: ViernesSpacing.xs),

        ViernesConversationCard(
          title: 'Mike Johnson',
          lastMessage: 'Perfect! See you at 3 PM',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isOnline: true,
          unreadCount: 0,
          onTap: () => _showSnackBar(context, 'Tapped on Mike Johnson conversation'),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}