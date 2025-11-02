import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/insight_parser.dart';

/// Purchase Intention Chart Widget
///
/// Displays a donut chart showing High/Medium/Low distribution
/// with the current purchase intention value prominently displayed.
///
/// Features:
/// - Donut chart visualization with fl_chart
/// - Responsive sizing (adapts to mobile/tablet)
/// - Color-coded segments (Green/Yellow/Red)
/// - Legend with color indicators
/// - Large center text showing current intention
/// - Supports dark/light themes
/// - Parses multilingual insight data
///
/// Example:
/// ```dart
/// PurchaseIntentionChart(
///   currentIntention: '{"en": "High", "es": "Alta"}',
///   distribution: {
///     'high': 70,
///     'medium': 20,
///     'low': 10,
///   },
///   isDark: false,
/// )
/// ```
class PurchaseIntentionChart extends StatelessWidget {
  /// Current purchase intention value (can be JSON string or plain text)
  final String? currentIntention;

  /// Distribution data: {'high': 70, 'medium': 20, 'low': 10}
  /// If null, uses mock data for demonstration
  final Map<String, double>? distribution;

  /// Dark mode flag
  final bool isDark;

  /// Language code for multilingual parsing
  final String languageCode;

  /// Chart size (diameter)
  final double size;

  const PurchaseIntentionChart({
    super.key,
    this.currentIntention,
    this.distribution,
    required this.isDark,
    this.languageCode = 'en',
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    // Parse current intention value
    final parsedIntention = currentIntention != null
        ? InsightParser.parse(currentIntention!, languageCode: languageCode)
        : 'N/A';

    // Use provided distribution or mock data
    final data = distribution ??
        {
          'high': 70.0,
          'medium': 20.0,
          'low': 10.0,
        };

    // Responsive size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final chartSize = screenWidth < 768 ? size : size * 1.2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Donut Chart
        SizedBox(
          height: chartSize,
          child: _buildDonutChart(data),
        ),
        const SizedBox(height: ViernesSpacing.md),

        // Current Value Display
        _buildCurrentValue(parsedIntention),
        const SizedBox(height: ViernesSpacing.md),

        // Legend
        _buildLegend(),
      ],
    );
  }

  /// Build the donut chart
  Widget _buildDonutChart(Map<String, double> data) {
    final high = data['high'] ?? 0.0;
    final medium = data['medium'] ?? 0.0;
    final low = data['low'] ?? 0.0;

    return PieChart(
      PieChartData(
        // Make it a donut chart with center hole
        centerSpaceRadius: size * 0.25,

        // Section styling
        sectionsSpace: 2,

        // Hide touch interactions for now
        pieTouchData: PieTouchData(enabled: false),

        // Chart sections
        sections: [
          // High intention
          if (high > 0)
            PieChartSectionData(
              value: high,
              title: '${high.toInt()}%',
              color: ViernesColors.success,
              radius: size * 0.15,
              titleStyle: ViernesTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

          // Medium intention
          if (medium > 0)
            PieChartSectionData(
              value: medium,
              title: '${medium.toInt()}%',
              color: ViernesColors.warning,
              radius: size * 0.15,
              titleStyle: ViernesTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

          // Low intention
          if (low > 0)
            PieChartSectionData(
              value: low,
              title: '${low.toInt()}%',
              color: ViernesColors.danger,
              radius: size * 0.15,
              titleStyle: ViernesTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  /// Build current value display
  Widget _buildCurrentValue(String value) {
    if (value.isEmpty || value == 'N/A') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(
          value,
          style: ViernesTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: _getPurchaseIntentionColor(value),
          ),
        ),
        const SizedBox(height: ViernesSpacing.xs),
        Text(
          'Current Intention',
          style: ViernesTextStyles.bodySmall.copyWith(
            color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                .withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Build legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('High', ViernesColors.success),
        _buildLegendItem('Medium', ViernesColors.warning),
        _buildLegendItem('Low', ViernesColors.danger),
      ],
    );
  }

  /// Build a single legend item
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: ViernesTextStyles.labelSmall.copyWith(
            color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
          ),
        ),
      ],
    );
  }

  /// Get color based on purchase intention value
  Color _getPurchaseIntentionColor(String intention) {
    final normalized = intention.toLowerCase().trim();

    if (normalized == 'high' || normalized == 'alta' || normalized == 'alto') {
      return ViernesColors.success;
    } else if (normalized == 'medium' ||
        normalized == 'media' ||
        normalized == 'medio') {
      return ViernesColors.warning;
    } else if (normalized == 'low' || normalized == 'baja' || normalized == 'bajo') {
      return ViernesColors.danger;
    }

    return ViernesColors.info;
  }
}
