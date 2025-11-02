import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';

/// Info Row Widget
///
/// Displays an icon + label + value row for customer information.
/// Used throughout customer detail sections.
///
/// Example:
/// ```dart
/// InfoRow(
///   icon: Icons.email,
///   label: 'Email',
///   value: 'john@example.com',
///   isDark: isDark,
/// )
/// ```
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted
                ? (isDark ? ViernesColors.accent : ViernesColors.primary)
                : (isDark ? ViernesColors.primaryLight : ViernesColors.textLight)
                    .withValues(alpha: 0.6),
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ViernesTextStyles.labelSmall.copyWith(
                    color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: ViernesTextStyles.bodyText.copyWith(
                    color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
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
