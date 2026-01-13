import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Consumption Chart Widget
///
/// Displays a donut chart showing consumption metrics (messages or minutes).
/// Features:
/// - Donut chart with "Usado" label in center
/// - Used portion in gray, remaining in theme color
/// - Metrics breakdown below the chart
/// - Support for recharged minutes display
class ConsumptionChart extends StatelessWidget {
  final String title;
  final double total;
  final double consumed;
  final double? recharged;
  final bool isMinutes;
  final bool isLoading;

  const ConsumptionChart({
    super.key,
    required this.title,
    required this.total,
    required this.consumed,
    this.recharged,
    this.isMinutes = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = total - consumed;
    final usedPercentage = total > 0 ? (consumed / total * 100) : 0.0;

    return ViernesGlassmorphismCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Donut Chart
          SizedBox(
            height: 160,
            child: isLoading
                ? _buildLoadingChart(isDark)
                : _buildChart(context, isDark, remaining, usedPercentage),
          ),

          const SizedBox(height: 16),

          // Metrics
          _buildMetrics(context, isDark, remaining),
        ],
      ),
    );
  }

  Widget _buildLoadingChart(bool isDark) {
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

  Widget _buildChart(BuildContext context, bool isDark, double remaining, double usedPercentage) {
    // Colors
    const usedColor = Color(0xFFB0B0B0); // Gray for used
    const remainingColor = ViernesColors.success; // Green for remaining

    // Handle edge cases
    final hasData = total > 0;
    final consumedValue = hasData ? consumed : 1.0;
    final remainingValue = hasData ? (remaining > 0 ? remaining : 0.0) : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sections: [
              // Used section (gray)
              PieChartSectionData(
                color: usedColor,
                value: consumedValue,
                title: '',
                radius: 25,
                showTitle: false,
              ),
              // Remaining section (green)
              if (remainingValue > 0)
                PieChartSectionData(
                  color: remainingColor,
                  value: remainingValue,
                  title: '',
                  radius: 25,
                  showTitle: false,
                ),
            ],
            centerSpaceRadius: 50,
            sectionsSpace: 2,
            startDegreeOffset: -90,
          ),
        ),
        // Center label
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.used,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ViernesColors.textDark.withValues(alpha: 0.7)
                    : ViernesColors.textLight.withValues(alpha: 0.7),
              ),
            ),
            if (hasData)
              Text(
                '${usedPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ViernesColors.textDark.withValues(alpha: 0.5)
                      : ViernesColors.textLight.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetrics(BuildContext context, bool isDark, double remaining) {
    final formatter = NumberFormat('#,###', 'es');
    final textColor = isDark ? ViernesColors.textDark : ViernesColors.textLight;

    return Column(
      children: [
        // Total
        _buildMetricRow(
          label: isMinutes ? '${AppLocalizations.of(context)!.totalMinutes}:' : '${AppLocalizations.of(context)!.totalMessages}:',
          value: isMinutes
              ? formatter.format(total.round())
              : formatter.format(total.toInt()),
          valueColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Consumed
        _buildMetricRow(
          label: isMinutes ? '${AppLocalizations.of(context)!.consumedMinutes}:' : '${AppLocalizations.of(context)!.consumedMessages}:',
          value: isMinutes
              ? consumed.toStringAsFixed(2)
              : formatter.format(consumed.toInt()),
          valueColor: textColor,
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Remaining
        _buildMetricRow(
          label: '${AppLocalizations.of(context)!.remaining}:',
          value: isMinutes
              ? remaining.toStringAsFixed(2)
              : formatter.format(remaining.toInt()),
          valueColor: ViernesColors.success,
          isDark: isDark,
        ),

        // Recharged (only for minutes)
        if (isMinutes && recharged != null && recharged! > 0) ...[
          const SizedBox(height: 8),
          _buildMetricRow(
            label: '${AppLocalizations.of(context)!.rechargedMinutes}:',
            value: formatter.format(recharged!.round()),
            valueColor: ViernesColors.accent,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required Color valueColor,
    required bool isDark,
  }) {
    final labelColor = isDark
        ? ViernesColors.textDark.withValues(alpha: 0.8)
        : ViernesColors.textLight.withValues(alpha: 0.8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ViernesTextStyles.bodySmall.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: ViernesTextStyles.bodySmall.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
