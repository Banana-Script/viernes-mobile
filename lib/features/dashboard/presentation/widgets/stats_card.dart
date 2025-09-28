import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.color,
    this.backgroundColor,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? ViernesColors.getThemePrimary(isDark);
    final defaultBackgroundColor = backgroundColor ?? ViernesColors.getControlBackground(isDark);

    return Card(
      elevation: 2,
      color: defaultBackgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(ViernesSpacing.md),
          child: isLoading
              ? _buildLoadingContent()
              : _buildContent(context, defaultColor, isDark),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        Container(
          height: 24,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: ViernesSpacing.sm),
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha:0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: ViernesSpacing.xs),
              Icon(
                icon,
                color: color,
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: ViernesSpacing.xs),
        Flexible(
          child: Text(
            value,
            style: ViernesTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: ViernesSpacing.xs),
          Text(
            subtitle!,
            style: ViernesTextStyles.caption.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha:0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class GradientStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final LinearGradient gradient;
  final bool isLoading;
  final VoidCallback? onTap;

  const GradientStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.gradient = ViernesColors.viernesGradient,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(ViernesSpacing.md),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? _buildLoadingContent()
              : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 16,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        Container(
          height: 24,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: ViernesSpacing.sm),
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha:0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: ViernesSpacing.xs),
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: ViernesSpacing.xs),
        Flexible(
          child: Text(
            value,
            style: ViernesTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: ViernesSpacing.xs),
          Text(
            subtitle!,
            style: ViernesTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha:0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}