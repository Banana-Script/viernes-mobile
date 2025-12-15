import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../domain/entities/ai_human_stats.dart';

/// AI vs Human Conversations Chart
///
/// Displays conversation distribution between AI-only and human-assisted
/// with improved visual design per UI designer recommendations:
/// - AI: Cyan (#51F5F8) with gradient
/// - Human: Orange (#E2A03F) with gradient
/// - Interactive touch feedback
/// - Icons in legend
class AiHumanChart extends StatefulWidget {
  final AiHumanStats? stats;
  final bool isLoading;

  const AiHumanChart({
    super.key,
    required this.stats,
    this.isLoading = false,
  });

  @override
  State<AiHumanChart> createState() => _AiHumanChartState();
}

class _AiHumanChartState extends State<AiHumanChart>
    with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // UI Designer recommended colors
  static const Color aiColor = Color(0xFF51F5F8); // Cyan
  static const Color aiColorDark = Color(0xFF3DD8DB); // Darker cyan for gradient
  static const Color humanColor = Color(0xFFE2A03F); // Orange
  static const Color humanColorDark = Color(0xFFC88A2E); // Darker orange for gradient

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ViernesGlassmorphismCard(
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // Accent gradient border for primary chart
          border: Border.all(
            color: isDark
                ? aiColor.withValues(alpha: 0.2)
                : ViernesColors.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [aiColor.withValues(alpha: 0.2), aiColorDark.withValues(alpha: 0.1)]
                            : [ViernesColors.primary.withValues(alpha: 0.1), ViernesColors.primary.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      color: isDark ? aiColor : ViernesColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI vs Human Conversations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ViernesSpacing.lg),
              SizedBox(
                height: 200,
                child: widget.isLoading
                    ? _buildLoadingChart(context)
                    : widget.stats == null
                        ? _buildEmptyChart(isDark)
                        : AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return _buildChart(isDark);
                            },
                          ),
              ),
              const SizedBox(height: 24),
              if (!widget.isLoading && widget.stats != null) _buildSummary(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: isDark ? aiColor : ViernesColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading chart...',
            style: ViernesTextStyles.caption.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: 48,
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No conversation data available',
            style: ViernesTextStyles.bodyText.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final aiPercentage = widget.stats!.aiOnly.percentage;
    final humanPercentage = widget.stats!.humanAssisted.percentage;

    // Animate radius based on touch
    final aiRadius = _touchedIndex == 0 ? 70.0 : 65.0;
    final humanRadius = _touchedIndex == 1 ? 70.0 : 65.0;

    final sections = [
      PieChartSectionData(
        color: aiColor,
        value: widget.stats!.aiOnly.count.toDouble() * _animation.value,
        title: aiPercentage > 5 ? '${aiPercentage.toStringAsFixed(0)}%' : '',
        radius: aiRadius * _animation.value,
        titleStyle: ViernesTextStyles.caption.copyWith(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: _touchedIndex == 0 ? 14 : 12,
        ),
        badgeWidget: _touchedIndex == 0
            ? _buildBadge(Icons.smart_toy_rounded, aiColor)
            : null,
        badgePositionPercentageOffset: 1.3,
        gradient: const LinearGradient(
          colors: [aiColor, aiColorDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      PieChartSectionData(
        color: humanColor,
        value: widget.stats!.humanAssisted.count.toDouble() * _animation.value,
        title: humanPercentage > 5 ? '${humanPercentage.toStringAsFixed(0)}%' : '',
        radius: humanRadius * _animation.value,
        titleStyle: ViernesTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: _touchedIndex == 1 ? 14 : 12,
        ),
        badgeWidget: _touchedIndex == 1
            ? _buildBadge(Icons.support_agent_rounded, humanColor)
            : null,
        badgePositionPercentageOffset: 1.3,
        gradient: const LinearGradient(
          colors: [humanColor, humanColorDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 45,
        sectionsSpace: 3,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = null;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;

              // Haptic feedback on touch
              if (event is FlTapUpEvent) {
                HapticFeedback.lightImpact();
              }
            });
          },
        ),
        centerSpaceColor: Colors.transparent,
      ),
      swapAnimationDuration: const Duration(milliseconds: 300),
      swapAnimationCurve: Curves.easeOutCubic,
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 16,
        color: color == aiColor ? Colors.black87 : Colors.white,
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    return Column(
      children: [
        // Legend items with icons
        _buildLegendItem(
          'AI Only',
          widget.stats!.aiOnly.count,
          widget.stats!.aiOnly.percentage,
          aiColor,
          Icons.smart_toy_outlined,
          isDark,
          isHighlighted: _touchedIndex == 0,
        ),
        const SizedBox(height: ViernesSpacing.md),
        _buildLegendItem(
          'Human Assisted',
          widget.stats!.humanAssisted.count,
          widget.stats!.humanAssisted.percentage,
          humanColor,
          Icons.support_agent_outlined,
          isDark,
          isHighlighted: _touchedIndex == 1,
        ),
        const SizedBox(height: ViernesSpacing.lg),
        // Total conversations with inner glow
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      ViernesColors.getBorderColor(isDark).withValues(alpha: 0.15),
                      ViernesColors.getBorderColor(isDark).withValues(alpha: 0.08),
                    ]
                  : [
                      ViernesColors.getBorderColor(isDark).withValues(alpha: 0.08),
                      ViernesColors.getBorderColor(isDark).withValues(alpha: 0.04),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Conversations',
                    style: ViernesTextStyles.bodyText.copyWith(
                      color: ViernesColors.getTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? aiColor.withValues(alpha: 0.15)
                      : ViernesColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.stats!.totalConversations.toString(),
                  style: ViernesTextStyles.bodyText.copyWith(
                    color: isDark ? aiColor : ViernesColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    String label,
    int count,
    double percentage,
    Color color,
    IconData icon,
    bool isDark, {
    bool isHighlighted = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isHighlighted
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Icon with color background
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          // Color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          // Label
          Expanded(
            child: Text(
              label,
              style: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark),
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          // Percentage
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: ViernesTextStyles.caption.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          // Count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isHighlighted ? 0.25 : 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count.toString(),
              style: ViernesTextStyles.bodyText.copyWith(
                color: color == aiColor && !isDark ? Colors.black87 : color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
