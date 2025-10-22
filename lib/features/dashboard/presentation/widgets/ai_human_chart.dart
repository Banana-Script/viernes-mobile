import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../domain/entities/ai_human_stats.dart';

class AiHumanChart extends StatelessWidget {
  final AiHumanStats? stats;
  final bool isLoading;

  const AiHumanChart({
    super.key,
    required this.stats,
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
            'AI vs Human Conversations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
            const SizedBox(height: ViernesSpacing.md),
            SizedBox(
              height: 200,
              child: isLoading
                  ? _buildLoadingChart(context)
                  : stats == null
                      ? _buildEmptyChart(isDark)
                      : _buildChart(isDark),
            ),
          const SizedBox(height: 20),
          if (!isLoading && stats != null) _buildSummary(isDark),
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

  Widget _buildEmptyChart(bool isDark) {
    return Center(
      child: Text(
        'No conversation data available',
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha:0.6),
        ),
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final sections = [
      PieChartSectionData(
        color: ViernesColors.accent,
        value: stats!.aiOnly.count.toDouble(),
        title: '${stats!.aiOnly.percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: ViernesTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: ViernesColors.secondary,
        value: stats!.humanAssisted.count.toDouble(),
        title: '${stats!.humanAssisted.percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: ViernesTextStyles.caption.copyWith(
          color: ViernesColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
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

  Widget _buildSummary(bool isDark) {
    return Column(
      children: [
        _buildLegendItem(
          'AI Only',
          stats!.aiOnly.count,
          ViernesColors.accent,
          isDark,
        ),
        const SizedBox(height: ViernesSpacing.sm),
        _buildLegendItem(
          'Human Assisted',
          stats!.humanAssisted.count,
          ViernesColors.secondary,
          isDark,
        ),
        const SizedBox(height: ViernesSpacing.md),
        Container(
          padding: const EdgeInsets.all(ViernesSpacing.sm),
          decoration: BoxDecoration(
            color: ViernesColors.getBorderColor(isDark).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Conversations',
                style: ViernesTextStyles.bodyText.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                stats!.totalConversations.toString(),
                style: ViernesTextStyles.bodyText.copyWith(
                  color: ViernesColors.getThemePrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, int count, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: ViernesSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: ViernesTextStyles.bodyText.copyWith(
              color: ViernesColors.getTextColor(isDark),
            ),
          ),
        ),
        Text(
          count.toString(),
          style: ViernesTextStyles.bodyText.copyWith(
            color: ViernesColors.getTextColor(isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}