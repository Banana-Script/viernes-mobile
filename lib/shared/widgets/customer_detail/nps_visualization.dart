import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/insight_parser.dart';

/// NPS Visualization Widget
///
/// Displays Net Promoter Score (NPS) with:
/// - Large number display (1-10 scale)
/// - Visual gradient scale (red → yellow → green)
/// - Labels: Detractors (1-6), Passive (7-8), Promoters (9-10)
/// - Color-coded based on score
///
/// Features:
/// - Responsive sizing
/// - Multilingual support
/// - Dark/light theme support
/// - WCAG compliant colors
/// - Accessibility labels
///
/// Example:
/// ```dart
/// NPSVisualization(
///   npsValue: '{"en": "8", "es": "8"}',
///   isDark: false,
///   languageCode: 'en',
/// )
/// ```
class NPSVisualization extends StatelessWidget {
  /// NPS value (can be JSON string or plain text, should be 1-10)
  final String? npsValue;

  /// Dark mode flag
  final bool isDark;

  /// Language code for multilingual parsing
  final String languageCode;

  /// Show labels flag
  final bool showLabels;

  /// Show scale numbers flag
  final bool showScaleNumbers;

  const NPSVisualization({
    super.key,
    this.npsValue,
    required this.isDark,
    this.languageCode = 'en',
    this.showLabels = true,
    this.showScaleNumbers = true,
  });

  @override
  Widget build(BuildContext context) {
    // Parse NPS value
    final parsedValue = npsValue != null
        ? InsightParser.parse(npsValue!, languageCode: languageCode)
        : '';

    final npsInt = int.tryParse(parsedValue) ?? 5;

    // Clamp value to 1-10 range
    final clampedNPS = npsInt.clamp(1, 10);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Large number display
        _buildNPSNumber(clampedNPS),
        const SizedBox(height: ViernesSpacing.sm),

        // Category labels
        if (showLabels) ...[
          _buildCategoryLabels(),
          const SizedBox(height: ViernesSpacing.xs),
        ],

        // Gradient bar
        _buildGradientBar(clampedNPS),
        const SizedBox(height: ViernesSpacing.xs),

        // Scale numbers
        if (showScaleNumbers) _buildScaleNumbers(clampedNPS),
      ],
    );
  }

  /// Build large NPS number display
  Widget _buildNPSNumber(int nps) {
    return Semantics(
      label: 'Net Promoter Score: $nps out of 10, ${_getNPSCategory(nps)}',
      child: Text(
        nps.toString(),
        style: ViernesTextStyles.h1.copyWith(
          fontWeight: FontWeight.w700,
          color: _getNPSColor(nps),
          fontSize: 56,
        ),
      ),
    );
  }

  /// Build category labels (Detractors, Passive, Promoters)
  Widget _buildCategoryLabels() {
    final textColor =
        (isDark ? ViernesColors.textDark : ViernesColors.textLight).withValues(alpha: 0.6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Detractors',
            style: ViernesTextStyles.labelSmall.copyWith(color: textColor),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          child: Text(
            'Passive',
            style: ViernesTextStyles.labelSmall.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Promoters',
            style: ViernesTextStyles.labelSmall.copyWith(color: textColor),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  /// Build gradient bar with indicator
  Widget _buildGradientBar(int nps) {
    return Stack(
      children: [
        // Gradient background
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [
                ViernesColors.danger, // Red (Detractors)
                Color(0xFFF59E0B), // Yellow (Passive)
                ViernesColors.success, // Green (Promoters)
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        ),

        // Position indicator
        Positioned(
          left: _calculateIndicatorPosition(nps),
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  /// Build scale numbers (1-10)
  Widget _buildScaleNumbers(int currentNPS) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(10, (index) {
        final number = index + 1;
        final isCurrentValue = number == currentNPS;

        return Text(
          number.toString(),
          style: ViernesTextStyles.labelSmall.copyWith(
            fontWeight: isCurrentValue ? FontWeight.w700 : FontWeight.w400,
            color: isCurrentValue
                ? _getNPSColor(currentNPS)
                : (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }

  /// Calculate indicator position on gradient bar
  double _calculateIndicatorPosition(int nps) {
    // Calculate position as percentage of total width
    // Account for padding/margin
    final percentage = (nps - 1) / 9; // 0 to 1 range
    return percentage * 100; // This will be percentage of parent width
  }

  /// Get NPS color based on score
  Color _getNPSColor(int nps) {
    if (nps >= 9) {
      return ViernesColors.success; // Promoters
    } else if (nps >= 7) {
      return ViernesColors.warning; // Passive
    } else {
      return ViernesColors.danger; // Detractors
    }
  }

  /// Get NPS category text
  String _getNPSCategory(int nps) {
    if (nps >= 9) {
      return 'Promoter';
    } else if (nps >= 7) {
      return 'Passive';
    } else {
      return 'Detractor';
    }
  }
}
