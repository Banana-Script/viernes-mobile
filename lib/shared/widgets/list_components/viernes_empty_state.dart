import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../viernes_glassmorphism_card.dart';

/// Viernes Empty State Widget
///
/// Displays an informative empty state when no items are found.
///
/// Features:
/// - Customizable icon with gradient background
/// - Clear messaging with optional description
/// - Optional action button with gradient styling
/// - Glassmorphism design
/// - Theme-aware colors (light/dark mode)
class ViernesEmptyState extends StatelessWidget {
  /// Main message to display
  final String message;

  /// Optional description text
  final String? description;

  /// Icon to display (uses filter_list_off when hasFilters is true)
  final IconData icon;

  /// Whether filters are active (changes icon to filter_list_off)
  final bool hasFilters;

  /// Optional action button label
  final String? actionLabel;

  /// Optional action button callback
  final VoidCallback? onActionPressed;

  const ViernesEmptyState({
    super.key,
    required this.message,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.hasFilters = false,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayIcon = hasFilters ? Icons.filter_list_off : icon;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ViernesSpacing.xl),
        child: ViernesGlassmorphismCard(
          borderRadius: ViernesSpacing.radius24,
          padding: const EdgeInsets.all(ViernesSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDark ? ViernesColors.accent : ViernesColors.secondary)
                          .withValues(alpha: 0.2),
                      (isDark ? ViernesColors.secondary : ViernesColors.accent)
                          .withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  displayIcon,
                  size: 48,
                  color: isDark ? ViernesColors.accent : ViernesColors.primary,
                ),
              ),
              const SizedBox(height: ViernesSpacing.lg),

              // Message
              Text(
                message,
                style: ViernesTextStyles.h4.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                ),
                textAlign: TextAlign.center,
              ),

              if (description != null) ...[
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  description!,
                  style: ViernesTextStyles.bodyText.copyWith(
                    color:
                        ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Action button
              if (onActionPressed != null && actionLabel != null) ...[
                const SizedBox(height: ViernesSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ViernesColors.secondary.withValues(alpha: 0.8),
                        ViernesColors.accent.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? ViernesColors.accent
                                : ViernesColors.secondary)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onActionPressed,
                      borderRadius:
                          BorderRadius.circular(ViernesSpacing.radius14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ViernesSpacing.lg,
                          vertical: ViernesSpacing.md,
                        ),
                        child: Text(
                          actionLabel!,
                          style: ViernesTextStyles.buttonMedium.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
