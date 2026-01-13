import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

class TagsChart extends StatelessWidget {
  final Map<String, int> tags;
  final bool isLoading;

  const TagsChart({
    super.key,
    required this.tags,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ViernesGlassmorphismCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.conversationTags ?? 'Conversation Tags',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: isLoading
                ? _buildLoadingChart(context)
                : tags.isEmpty
                    ? _buildEmptyChart(context, isDark)
                    : _buildChart(isDark),
          ),
          const SizedBox(height: 20),
          if (!isLoading && tags.isNotEmpty) _buildLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildLoadingChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          color: isDark ? ViernesColors.accent : ViernesColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, bool isDark) {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.noTagData ?? 'No tag data available',
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha:0.6),
        ),
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final colors = _getTagColors();
    final sections = _createPieChartSections(colors);

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Handle touch events if needed
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(List<Color> colors) {
    final total = tags.values.fold(0, (sum, value) => sum + value);
    final sortedTags = tags.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.asMap().entries.map((entry) {
      final index = entry.key;
      final tagEntry = entry.value;
      final percentage = (tagEntry.value / total * 100);
      final color = colors[index % colors.length];

      return PieChartSectionData(
        color: color,
        value: tagEntry.value.toDouble(),
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 50,
        titleStyle: ViernesTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(bool isDark) {
    final colors = _getTagColors();
    final sortedTags = tags.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: ViernesSpacing.md,
      runSpacing: ViernesSpacing.sm,
      children: sortedTags.asMap().entries.map((entry) {
        final index = entry.key;
        final tagEntry = entry.value;
        final color = colors[index % colors.length];

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
            const SizedBox(width: ViernesSpacing.xs),
            Text(
              '${_formatTagLabel(tagEntry.key)} (${tagEntry.value})',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Color> _getTagColors() {
    return [
      ViernesColors.primary,
      ViernesColors.secondary,
      ViernesColors.accent,
      ViernesColors.success,
      ViernesColors.warning,
      ViernesColors.info,
      ViernesColors.danger,
      ViernesColors.primaryLight,
    ];
  }

  String _formatTagLabel(String tag) {
    if (tag.length <= 10) {
      return tag.replaceAll('_', ' ').toLowerCase().split(' ').map((word) {
        return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '';
      }).join(' ');
    }
    return '${tag.substring(0, 8)}..';
  }
}