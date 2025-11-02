import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/customer_insight_helper.dart';
import '../../../core/constants/insight_features.dart';
import '../../../features/customers/domain/entities/customer_entity.dart';
import '../viernes_glassmorphism_card.dart';
import 'section_header.dart';
import 'insight_badge.dart';

/// Sentiment Analysis Panel Widget
///
/// Displays sentiment analysis data in 4 subsections:
/// - Emotions (sentiment_analysis badge + sentiment_analysis_detail)
/// - Attitudes (attitude_analysis badge + attitude_analysis_details)
/// - Personality (personality_analysis badge + personality_analysis_details)
/// - Intentions (intentions_analysis badge + intentions_analysis_details)
///
/// Each subsection shows a badge with the value and detail text below.
/// Uses CustomerInsightHelper for centralized insight parsing.
class SentimentAnalysisPanel extends StatelessWidget {
  final CustomerEntity customer;
  final bool isDark;

  const SentimentAnalysisPanel({
    super.key,
    required this.customer,
    required this.isDark,
  });

  /// Get color for sentiment badges based on value
  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
      case 'positivo':
        return ViernesColors.success;
      case 'negative':
      case 'negativo':
        return ViernesColors.danger;
      case 'neutral':
        return ViernesColors.warning;
      default:
        return isDark ? ViernesColors.accent : ViernesColors.primary;
    }
  }

  /// Build a sentiment subsection with badge and detail text
  Widget _buildSentimentSubsection({
    required String title,
    required String badgeValue,
    required String detailValue,
    required Color badgeColor,
  }) {
    // Skip if no badge value
    if (badgeValue.isEmpty || badgeValue == 'N/A') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ViernesTextStyles.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
          ),
        ),
        const SizedBox(height: ViernesSpacing.xs),
        InsightBadge(
          text: badgeValue,
          isDark: isDark,
          color: badgeColor,
        ),
        if (detailValue.isNotEmpty && detailValue != 'N/A') ...[
          const SizedBox(height: ViernesSpacing.xs),
          Text(
            detailValue,
            style: ViernesTextStyles.bodySmall.copyWith(
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    // Use CustomerInsightHelper instead of duplicated code
    final emotionsBadge = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.sentimentAnalysis,
      languageCode: languageCode,
    );
    final emotionsDetail = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.sentimentAnalysisDetail,
      languageCode: languageCode,
    );
    final attitudesBadge = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.attitudeAnalysis,
      languageCode: languageCode,
    );
    final attitudesDetail = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.attitudeAnalysisDetails,
      languageCode: languageCode,
    );
    final personalityBadge = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.personalityAnalysis,
      languageCode: languageCode,
    );
    final personalityDetail = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.personalityAnalysisDetails,
      languageCode: languageCode,
    );
    final intentionsBadge = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.intentionsAnalysis,
      languageCode: languageCode,
    );
    final intentionsDetail = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.intentionsAnalysisDetails,
      languageCode: languageCode,
    );

    // Check if we have any sentiment data
    final hasAnyData = emotionsBadge.isNotEmpty ||
        attitudesBadge.isNotEmpty ||
        personalityBadge.isNotEmpty ||
        intentionsBadge.isNotEmpty;

    // Hide if no data
    if (!hasAnyData) {
      return const SizedBox.shrink();
    }

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.sentiment_satisfied_rounded,
            title: 'Sentiment Analysis',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.md),

          // Emotions subsection
          _buildSentimentSubsection(
            title: 'Emotions',
            badgeValue: emotionsBadge,
            detailValue: emotionsDetail,
            badgeColor: _getSentimentColor(emotionsBadge),
          ),

          // Add spacing between subsections if emotions has data
          if (emotionsBadge.isNotEmpty && emotionsBadge != 'N/A')
            const SizedBox(height: ViernesSpacing.md),

          // Attitudes subsection
          _buildSentimentSubsection(
            title: 'Attitudes',
            badgeValue: attitudesBadge,
            detailValue: attitudesDetail,
            badgeColor: ViernesColors.info,
          ),

          // Add spacing if attitudes has data
          if (attitudesBadge.isNotEmpty && attitudesBadge != 'N/A')
            const SizedBox(height: ViernesSpacing.md),

          // Personality subsection
          _buildSentimentSubsection(
            title: 'Personality',
            badgeValue: personalityBadge,
            detailValue: personalityDetail,
            badgeColor: ViernesColors.secondary,
          ),

          // Add spacing if personality has data
          if (personalityBadge.isNotEmpty && personalityBadge != 'N/A')
            const SizedBox(height: ViernesSpacing.md),

          // Intentions subsection
          _buildSentimentSubsection(
            title: 'Intentions',
            badgeValue: intentionsBadge,
            detailValue: intentionsDetail,
            badgeColor: ViernesColors.accent,
          ),
        ],
      ),
    );
  }
}
