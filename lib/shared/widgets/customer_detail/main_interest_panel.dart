import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/insight_parser.dart';
import 'insight_badge.dart';
import 'nps_visualization.dart';

/// Main Interest Panel Widget
///
/// Displays customer's main interest and related information:
/// - Main interest as a large, prominent badge
/// - Other topics as smaller badges
/// - Net Promoter Score visualization
///
/// Features:
/// - Parses multilingual insight data
/// - Responsive layout
/// - Dark/light theme support
/// - Handles comma-separated lists for other topics
/// - Includes NPS visualization component
///
/// Example:
/// ```dart
/// MainInterestPanel(
///   mainInterest: '{"en": "Payment Methods", "es": "Métodos de Pago"}',
///   otherTopics: '{"en": "Returns, Shipping, Tracking"}',
///   npsValue: '{"en": "8"}',
///   isDark: false,
///   languageCode: 'en',
/// )
/// ```
class MainInterestPanel extends StatelessWidget {
  /// Main interest value (JSON string or plain text)
  final String? mainInterest;

  /// Other topics (JSON string or plain text, comma-separated)
  final String? otherTopics;

  /// NPS value (JSON string or plain text, should be 1-10)
  final String? npsValue;

  /// Dark mode flag
  final bool isDark;

  /// Language code for multilingual parsing
  final String languageCode;

  /// Show divider before NPS section
  final bool showNPSDivider;

  const MainInterestPanel({
    super.key,
    this.mainInterest,
    this.otherTopics,
    this.npsValue,
    required this.isDark,
    this.languageCode = 'en',
    this.showNPSDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    // Parse main interest
    final parsedMainInterest = mainInterest != null
        ? InsightParser.parse(mainInterest!, languageCode: languageCode)
        : '';

    // Parse other topics
    final parsedOtherTopics = otherTopics != null
        ? InsightParser.parse(otherTopics!, languageCode: languageCode)
        : '';

    // Split other topics by comma
    final topicsList = parsedOtherTopics.isNotEmpty
        ? parsedOtherTopics.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
        : <String>[];

    // Parse NPS value
    final parsedNPS = npsValue != null
        ? InsightParser.parse(npsValue!, languageCode: languageCode)
        : '';

    final hasMainInterest = parsedMainInterest.isNotEmpty && parsedMainInterest != 'N/A';
    final hasOtherTopics = topicsList.isNotEmpty;
    final hasNPS = parsedNPS.isNotEmpty && parsedNPS != 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Interest Section
        if (hasMainInterest) ...[
          _buildMainInterestBadge(parsedMainInterest),
          const SizedBox(height: ViernesSpacing.lg),
        ],

        // Other Topics Section
        if (hasOtherTopics) ...[
          _buildOtherTopicsSection(topicsList),
          const SizedBox(height: ViernesSpacing.lg),
        ],

        // NPS Section
        if (hasNPS) ...[
          if (showNPSDivider && (hasMainInterest || hasOtherTopics))
            Column(
              children: [
                Divider(
                  color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                      .withValues(alpha: 0.1),
                ),
                const SizedBox(height: ViernesSpacing.md),
              ],
            ),
          _buildNPSSection(parsedNPS),
        ],
      ],
    );
  }

  /// Build large main interest badge
  Widget _buildMainInterestBadge(String interest) {
    return Center(
      child: Semantics(
        label: 'Main interest: $interest',
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.lg,
            vertical: ViernesSpacing.md,
          ),
          decoration: BoxDecoration(
            color: ViernesColors.warning.withValues(alpha: 0.15),
            border: Border.all(
              color: ViernesColors.warning,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
          ),
          child: Text(
            interest.toUpperCase(),
            style: ViernesTextStyles.h6.copyWith(
              color: ViernesColors.warning,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Build other topics section with badges
  Widget _buildOtherTopicsSection(List<String> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Other Topics in Mind',
          style: ViernesTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        Wrap(
          spacing: ViernesSpacing.sm,
          runSpacing: ViernesSpacing.sm,
          children: topics.map((topic) {
            return InsightBadge(
              text: topic,
              isDark: isDark,
              color: ViernesColors.info,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build NPS section
  Widget _buildNPSSection(String nps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Net Promoter Score',
          style: ViernesTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
          ),
        ),
        const SizedBox(height: ViernesSpacing.md),
        NPSVisualization(
          npsValue: nps,
          isDark: isDark,
          languageCode: languageCode,
        ),
      ],
    );
  }
}
