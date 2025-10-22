import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Viernes Stats Card
///
/// Unified stats card with glassmorphism effect, replacing both StatsCard and GradientStatsCard.
/// Features:
/// - Glassmorphism styling matching auth pages
/// - Support for gradient accent on primary cards
/// - Color-coded icons with subtle backgrounds
/// - Loading state with shimmer effect
///
/// Usage:
/// ```dart
/// ViernesStatsCard(
///   title: 'Total Interactions',
///   value: '1,234',
///   subtitle: 'This month',
///   icon: Icons.chat_bubble_outline,
///   isPrimary: true,  // Uses gradient accent
/// )
/// ```
class ViernesStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool isPrimary;

  const ViernesStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.isLoading = false,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultAccent = accentColor ??
        (isDark ? ViernesColors.accent : ViernesColors.primary);

    return ViernesGlassmorphismCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: isLoading
          ? _buildLoadingContent()
          : _buildContent(isDark, defaultAccent),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 32,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(bool isDark, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header: Title and Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.getTextColor(isDark)
                      .withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Icon with gradient background if primary
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isPrimary
                    ? LinearGradient(
                        colors: [
                          ViernesColors.secondary.withValues(alpha: 0.3),
                          ViernesColors.accent.withValues(alpha: 0.3),
                        ],
                      )
                    : null,
                color: isPrimary ? null : accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isPrimary
                    ? (isDark
                        ? ViernesColors.accent
                        : ViernesColors.secondary)
                    : accentColor,
                size: 20,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Value
        Text(
          value,
          style: ViernesTextStyles.h3.copyWith(
            color: isPrimary
                ? (isDark ? ViernesColors.accent : ViernesColors.primary)
                : accentColor,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Subtitle
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: ViernesTextStyles.caption.copyWith(
              color: ViernesColors.getTextColor(isDark)
                  .withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// Keep old classes for backward compatibility (deprecated)
@Deprecated('Use ViernesStatsCard instead')
class StatsCard extends ViernesStatsCard {
  const StatsCard({
    super.key,
    required super.title,
    required super.value,
    super.subtitle,
    IconData? icon,
    Color? color,
    Color? backgroundColor,
    super.isLoading,
    super.onTap,
  }) : super(
          icon: icon ?? Icons.analytics,
          accentColor: color,
        );
}

@Deprecated('Use ViernesStatsCard with isPrimary: true instead')
class GradientStatsCard extends ViernesStatsCard {
  const GradientStatsCard({
    super.key,
    required super.title,
    required super.value,
    super.subtitle,
    IconData? icon,
    LinearGradient? gradient,
    super.isLoading,
    super.onTap,
  }) : super(
          icon: icon ?? Icons.analytics,
          isPrimary: true,
        );
}
