import 'package:flutter/material.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_text_styles.dart';
import 'viernes_glassmorphism_card.dart';

/// Viernes Settings Tile
///
/// A navigable settings item with icon, title, subtitle (preview of current state),
/// and chevron indicator. Used for drill-down navigation to settings sub-pages.
///
/// Usage:
/// ```dart
/// ViernesSettingsTile(
///   icon: Icons.notifications,
///   title: 'Notificaciones',
///   subtitle: '3 de 5 activadas',
///   onTap: () => Navigator.push(...),
/// )
/// ```
class ViernesSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final bool showChevron;

  const ViernesSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? ViernesColors.getTextColor(isDark);

    return ViernesGlassmorphismCard(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          children: [
            // Icon container with gradient background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    effectiveIconColor.withValues(alpha: 0.15),
                    effectiveIconColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ViernesTextStyles.bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ViernesColors.getTextColor(isDark),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: ViernesTextStyles.bodySmall.copyWith(
                        color: ViernesColors.getTextColor(isDark)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing widget or chevron
            if (trailing != null)
              trailing!
            else if (onTap != null && showChevron)
              Icon(
                Icons.chevron_right,
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.4),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
