import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/insight_parser.dart';
import '../viernes_glassmorphism_card.dart';
import 'section_header.dart';
import 'insight_badge.dart';

/// Interactions Panel Widget
///
/// Displays customer interactions metrics and suggested actions.
/// Shows:
/// - Interactions per month (large number display)
/// - Last interaction reasons (multiple badges)
/// - Actions to call (bullet list)
///
/// All fields support multilingual parsing.
///
/// Data fields from insights_info:
/// - `interactions_per_month`: Number of monthly interactions
/// - `last_interactions_reason`: Comma-separated list of reasons
/// - `actions_to_call`: Newline-separated list of suggested actions
///
/// Example:
/// ```dart
/// InteractionsPanel(
///   interactionsPerMonth: '12',
///   lastInteractionReasons: 'Returns, Exchange, Product inquiry',
///   actionsToCall: 'Send reminders\nOffer discounts\nImprove communication',
///   isDark: isDark,
///   languageCode: 'en',
/// )
/// ```
class InteractionsPanel extends StatelessWidget {
  final String? interactionsPerMonth;
  final String? lastInteractionReasons;
  final String? actionsToCall;
  final bool isDark;
  final String languageCode;

  const InteractionsPanel({
    super.key,
    this.interactionsPerMonth,
    this.lastInteractionReasons,
    this.actionsToCall,
    required this.isDark,
    this.languageCode = 'en',
  });

  /// Parse multilingual field
  String _parseField(String? value) {
    if (value == null || value.isEmpty) return '';
    return InsightParser.parse(value, languageCode: languageCode);
  }

  /// Parse comma-separated list
  List<String> _parseList(String? value) {
    if (value == null || value.isEmpty) return [];
    final parsed = _parseField(value);
    if (parsed.isEmpty) return [];

    // Split by comma and clean up
    return parsed
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Parse newline-separated list
  List<String> _parseNewlineList(String? value) {
    if (value == null || value.isEmpty) return [];
    final parsed = _parseField(value);
    if (parsed.isEmpty) return [];

    // Split by newline and clean up
    return parsed
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final parsedInteractions = _parseField(interactionsPerMonth);
    final reasonsList = _parseList(lastInteractionReasons);
    final actionsList = _parseNewlineList(actionsToCall);

    // If all fields are empty, don't show the panel
    if (parsedInteractions.isEmpty && reasonsList.isEmpty && actionsList.isEmpty) {
      return const SizedBox.shrink();
    }

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius24,
      padding: const EdgeInsets.all(ViernesSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SectionHeader(
            icon: Icons.timeline_rounded,
            title: 'Interactions & Actions',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.lg),

          // Interactions Per Month
          if (parsedInteractions.isNotEmpty) ...[
            _buildInteractionsPerMonth(parsedInteractions),
            const SizedBox(height: ViernesSpacing.lg),
          ],

          // Last Interaction Reasons
          if (reasonsList.isNotEmpty) ...[
            _buildLastInteractionReasons(reasonsList),
            const SizedBox(height: ViernesSpacing.lg),
          ],

          // Actions to Call
          if (actionsList.isNotEmpty) ...[
            _buildActionsToCall(actionsList),
          ],
        ],
      ),
    );
  }

  /// Build interactions per month display
  Widget _buildInteractionsPerMonth(String interactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interactions per month',
          style: ViernesTextStyles.label.copyWith(
            color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: ViernesSpacing.xs),
        Text(
          interactions,
          style: ViernesTextStyles.h1.copyWith(
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 48,
          ),
        ),
      ],
    );
  }

  /// Build last interaction reasons badges
  Widget _buildLastInteractionReasons(List<String> reasons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Interaction Reasons',
          style: ViernesTextStyles.label.copyWith(
            color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        Wrap(
          spacing: ViernesSpacing.sm,
          runSpacing: ViernesSpacing.sm,
          children: reasons.map((reason) {
            return InsightBadge(
              text: reason,
              isDark: isDark,
              color: ViernesColors.warning,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build actions to call bullet list
  Widget _buildActionsToCall(List<String> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions to Call:',
          style: ViernesTextStyles.label.copyWith(
            color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: ViernesSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? ViernesColors.accent : ViernesColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.sm),
                Expanded(
                  child: Text(
                    action,
                    style: ViernesTextStyles.bodyText.copyWith(
                      color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          )),
      ],
    );
  }
}
