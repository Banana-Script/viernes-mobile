import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/theme/insight_color_system.dart';

/// Insight Badge Widget
///
/// Displays an insight/tag badge with customizable color and text.
/// Uses the InsightColorSystem for WCAG 2.1 AA compliant colors.
///
/// Example:
/// ```dart
/// InsightBadge(
///   text: 'Technology',
///   isDark: isDark,
///   color: ViernesColors.info,
///   importance: InsightImportance.important,
/// )
/// ```
class InsightBadge extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final InsightImportance importance;

  const InsightBadge({
    super.key,
    required this.text,
    required this.isDark,
    this.color,
    this.icon,
    this.onTap,
    this.importance = InsightImportance.normal,
  });

  @override
  Widget build(BuildContext context) {
    // Get base color (semantic color)
    final badgeColor = color ?? (isDark ? ViernesColors.accent : ViernesColors.primary);

    // Get WCAG-compliant colors from the color system
    final colors = InsightColorSystem.getColors(
      baseColor: badgeColor,
      isDark: isDark,
      importance: importance,
    );

    // Get border width based on importance
    final borderWidth = InsightColorSystem.getBorderWidth(importance);

    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.space3,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        border: Border.all(
          color: colors.border,
          width: borderWidth,
        ),
        boxShadow: colors.shadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: colors.text,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: ViernesTextStyles.labelSmall.copyWith(
                color: colors.text,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        child: content,
      );
    }

    return content;
  }
}
