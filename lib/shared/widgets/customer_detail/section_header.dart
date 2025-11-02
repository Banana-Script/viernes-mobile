import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';

/// Section Header Widget
///
/// Reusable section header for customer detail sections.
/// Features:
/// - Icon on the left
/// - Title text
/// - Optional action widget on the right (e.g., expand icon)
/// - Consistent spacing and styling
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? action;
  final bool isDark;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.isDark,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? ViernesColors.accent : ViernesColors.primary,
        ),
        const SizedBox(width: ViernesSpacing.sm),
        Expanded(
          child: Text(
            title,
            style: ViernesTextStyles.h6.copyWith(
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.xs),
          child: content,
        ),
      );
    }

    return content;
  }
}
