import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';

class SentimentChart extends StatelessWidget {
  final Map<String, int> sentiments;
  final bool isLoading;

  const SentimentChart({
    super.key,
    required this.sentiments,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: ViernesColors.getControlBackground(isDark),
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sentiment Analysis',
              style: ViernesTextStyles.h3.copyWith(
                color: ViernesColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ViernesSpacing.md),
            SizedBox(
              height: 200,
              child: isLoading
                  ? _buildLoadingChart()
                  : sentiments.isEmpty
                      ? _buildEmptyChart(isDark)
                      : _buildChart(isDark),
            ),
            const SizedBox(height: ViernesSpacing.md),
            if (!isLoading && sentiments.isNotEmpty) _buildLegend(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingChart() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ViernesColors.primary),
      ),
    );
  }

  Widget _buildEmptyChart(bool isDark) {
    return Center(
      child: Text(
        'No sentiment data available',
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha:0.6),
        ),
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final colors = _getSentimentColors();
    final sections = _createPieChartSections(colors);

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

  List<PieChartSectionData> _createPieChartSections(Map<String, Color> colors) {
    final total = sentiments.values.fold(0, (sum, value) => sum + value);

    return sentiments.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[entry.key] ?? ViernesColors.primaryLight;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: ViernesTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(bool isDark) {
    final colors = _getSentimentColors();

    return Wrap(
      spacing: ViernesSpacing.md,
      runSpacing: ViernesSpacing.sm,
      children: sentiments.entries.map((entry) {
        final color = colors[entry.key] ?? ViernesColors.primaryLight;

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
              '${_formatSentimentLabel(entry.key)} (${entry.value})',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Map<String, Color> _getSentimentColors() {
    return {
      'satisfied': ViernesColors.success,
      'neutral': ViernesColors.info,
      'dissatisfied': ViernesColors.danger,
      'positive': ViernesColors.success,
      'negative': ViernesColors.danger,
      'mixed': ViernesColors.warning,
    };
  }

  String _formatSentimentLabel(String sentiment) {
    return sentiment[0].toUpperCase() + sentiment.substring(1);
  }
}