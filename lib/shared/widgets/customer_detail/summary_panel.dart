import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/customer_insight_helper.dart';
import '../../../core/constants/insight_features.dart';
import '../../../features/customers/domain/entities/customer_entity.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../viernes_glassmorphism_card.dart';
import 'section_header.dart';

/// Summary Panel Widget
///
/// Displays the parsed `summary_profile` insight value in a glassmorphism card.
/// Uses CustomerInsightHelper for centralized insight parsing.
/// Handles null/empty values gracefully.
class SummaryPanel extends StatelessWidget {
  final CustomerEntity customer;
  final bool isDark;

  const SummaryPanel({
    super.key,
    required this.customer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);

    // Use CustomerInsightHelper instead of duplicated code
    final summaryValue = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.summaryProfile,
      languageCode: languageCode,
    );

    // Hide if no data
    if (summaryValue.isEmpty || summaryValue == 'N/A') {
      return const SizedBox.shrink();
    }

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.summarize_rounded,
            title: l10n?.profileSummary ?? 'Profile Summary',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            summaryValue,
            style: ViernesTextStyles.bodyText.copyWith(
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.9),
              height: 1.6, // Better line height for readability
            ),
          ),
        ],
      ),
    );
  }
}
