import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../viernes_glassmorphism_card.dart';

/// Metric Card Widget
///
/// Displays a metric with an icon, label, and value.
/// Used in the 2x2 metrics grid on customer detail page.
///
/// Example:
/// ```dart
/// MetricCard(
///   icon: Icons.shopping_bag,
///   label: 'Total Purchases',
///   value: '24',
///   isDark: isDark,
/// )
/// ```
class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? iconColor;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(ViernesSpacing.sm),
            decoration: BoxDecoration(
              color: (iconColor ?? (isDark ? ViernesColors.accent : ViernesColors.primary))
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? (isDark ? ViernesColors.accent : ViernesColors.primary),
            ),
          ),
          const SizedBox(height: ViernesSpacing.sm),
          // Label
          Text(
            label,
            style: ViernesTextStyles.labelSmall.copyWith(
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: ViernesTextStyles.h4.copyWith(
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
