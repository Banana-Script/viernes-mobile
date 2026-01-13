import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

class CategoriesChart extends StatelessWidget {
  final Map<String, int> categories;
  final bool isLoading;

  const CategoriesChart({
    super.key,
    required this.categories,
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
            AppLocalizations.of(context)?.topCategories ?? 'Top Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: isLoading
                ? _buildLoadingChart(context)
                : categories.isEmpty
                    ? _buildEmptyChart(context, isDark)
                    : _buildChart(isDark),
          ),
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
        AppLocalizations.of(context)?.noCategoryData ?? 'No category data available',
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha:0.6),
        ),
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final sortedCategories = _getSortedCategories();
    final maxValue = sortedCategories.isEmpty
        ? 0.0
        : sortedCategories.first.value.toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2, // Add some padding to the top
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${sortedCategories[group.x.toInt()].key}\n${rod.toY.toInt()}',
                ViernesTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedCategories.length) {
                  return const Text('');
                }
                return Padding(
                  padding: const EdgeInsets.only(top: ViernesSpacing.xs),
                  child: Text(
                    _formatCategoryLabel(sortedCategories[index].key),
                    style: ViernesTextStyles.caption.copyWith(
                      color: ViernesColors.getTextColor(isDark),
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: ViernesTextStyles.caption.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: ViernesColors.getBorderColor(isDark),
              width: 1,
            ),
            left: BorderSide(
              color: ViernesColors.getBorderColor(isDark),
              width: 1,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: ViernesColors.getBorderColor(isDark).withValues(alpha:0.3),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: _createBarGroups(sortedCategories),
      ),
    );
  }

  List<MapEntry<String, int>> _getSortedCategories() {
    final entries = categories.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList(); // Show only top 5 categories
  }

  List<BarChartGroupData> _createBarGroups(List<MapEntry<String, int>> sortedCategories) {
    return sortedCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: categoryEntry.value.toDouble(),
            color: _getCategoryColor(index),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getCategoryColor(int index) {
    final colors = [
      ViernesColors.primary,
      ViernesColors.secondary,
      ViernesColors.accent,
      ViernesColors.success,
      ViernesColors.info,
    ];
    return colors[index % colors.length];
  }

  String _formatCategoryLabel(String category) {
    if (category.length <= 8) {
      return category[0].toUpperCase() + category.substring(1);
    }
    return '${category.substring(0, 6)}..';
  }
}