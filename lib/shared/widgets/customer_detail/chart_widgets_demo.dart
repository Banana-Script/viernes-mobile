import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../viernes_glassmorphism_card.dart';
import 'purchase_intention_chart.dart';
import 'nps_visualization.dart';
import 'main_interest_panel.dart';
import 'section_header.dart';

/// Chart Widgets Demo Page
///
/// This is a demonstration page showing all three chart widgets
/// with sample data. NOT intended for production use.
///
/// To view this demo:
/// 1. Add route to your router
/// 2. Navigate to /chart-demo
///
/// Example Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => ChartWidgetsDemo()),
/// );
/// ```
class ChartWidgetsDemo extends StatefulWidget {
  const ChartWidgetsDemo({super.key});

  @override
  State<ChartWidgetsDemo> createState() => _ChartWidgetsDemoState();
}

class _ChartWidgetsDemoState extends State<ChartWidgetsDemo> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark
          ? ViernesColors.backgroundDark
          : ViernesColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chart Widgets Demo'),
        actions: [
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDark = !_isDark;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ViernesSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo Instructions
            _buildInstructions(),
            const SizedBox(height: ViernesSpacing.lg),

            // Purchase Intention Chart Demo
            _buildPurchaseIntentionDemo(),
            const SizedBox(height: ViernesSpacing.lg),

            // NPS Visualization Demo
            _buildNPSDemo(),
            const SizedBox(height: ViernesSpacing.lg),

            // Main Interest Panel Demo
            _buildMainInterestDemo(),
            const SizedBox(height: ViernesSpacing.lg),

            // Combined Demo (as it would appear in production)
            _buildCombinedDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: ViernesColors.info,
            size: 32,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            'Chart Widgets Demo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _isDark
                  ? ViernesColors.textDark
                  : ViernesColors.textLight,
            ),
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            'This page demonstrates the three chart widgets created for the customer detail page refactor. '
            'Toggle dark mode with the button above.',
            style: TextStyle(
              fontSize: 14,
              color: (_isDark
                      ? ViernesColors.textDark
                      : ViernesColors.textLight)
                  .withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseIntentionDemo() {
    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.shopping_bag_rounded,
            title: 'Purchase Intention Chart',
            isDark: _isDark,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            'Displays customer purchase intention with donut chart visualization.',
            style: TextStyle(
              fontSize: 12,
              color: (_isDark
                      ? ViernesColors.textDark
                      : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: ViernesSpacing.md),
          PurchaseIntentionChart(
            currentIntention: 'High',
            distribution: {
              'high': 70.0,
              'medium': 20.0,
              'low': 10.0,
            },
            isDark: _isDark,
            languageCode: 'en',
          ),
        ],
      ),
    );
  }

  Widget _buildNPSDemo() {
    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.stars_rounded,
            title: 'NPS Visualization',
            isDark: _isDark,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            'Net Promoter Score with gradient scale and category labels.',
            style: TextStyle(
              fontSize: 12,
              color: (_isDark
                      ? ViernesColors.textDark
                      : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: ViernesSpacing.md),
          NPSVisualization(
            npsValue: '8',
            isDark: _isDark,
            languageCode: 'en',
            showLabels: true,
            showScaleNumbers: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInterestDemo() {
    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.interests_rounded,
            title: 'Main Interest Panel',
            isDark: _isDark,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            'Combined panel showing main interest, other topics, and NPS.',
            style: TextStyle(
              fontSize: 12,
              color: (_isDark
                      ? ViernesColors.textDark
                      : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: ViernesSpacing.md),
          MainInterestPanel(
            mainInterest: 'Payment Methods',
            otherTopics: 'Returns, Shipping, Tracking, Customer Support',
            npsValue: '9',
            isDark: _isDark,
            languageCode: 'en',
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedDemo() {
    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.dashboard_rounded,
            title: 'Combined Example (Production Layout)',
            isDark: _isDark,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            'How all widgets would appear together in the customer detail page.',
            style: TextStyle(
              fontSize: 12,
              color: (_isDark
                      ? ViernesColors.textDark
                      : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: ViernesSpacing.lg),

          // Purchase Intention
          Text(
            'Purchase Intention Analysis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isDark
                  ? ViernesColors.textDark
                  : ViernesColors.textLight,
            ),
          ),
          const SizedBox(height: ViernesSpacing.sm),
          PurchaseIntentionChart(
            currentIntention: 'Medium',
            distribution: {
              'high': 45.0,
              'medium': 35.0,
              'low': 20.0,
            },
            isDark: _isDark,
          ),
          const SizedBox(height: ViernesSpacing.xl),

          // Main Interest & NPS
          Text(
            'Interests & Feedback',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isDark
                  ? ViernesColors.textDark
                  : ViernesColors.textLight,
            ),
          ),
          const SizedBox(height: ViernesSpacing.sm),
          MainInterestPanel(
            mainInterest: 'Cloud Infrastructure',
            otherTopics: 'Security, DevOps, Kubernetes, Serverless',
            npsValue: '7',
            isDark: _isDark,
          ),
        ],
      ),
    );
  }
}
