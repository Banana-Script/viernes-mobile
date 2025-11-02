import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Customer Empty State Widget
///
/// Displays an informative empty state when no customers are found.
/// Features:
/// - Animated icon
/// - Clear messaging
/// - Optional action button
/// - Glassmorphism design
class CustomerEmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final bool hasFilters;

  const CustomerEmptyState({
    super.key,
    this.message = 'No customers found',
    this.description,
    this.onActionPressed,
    this.actionLabel,
    this.hasFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  hasFilters ? Icons.filter_list_off : Icons.people_outline,
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
                    color: ViernesColors.getTextColor(isDark)
                        .withValues(alpha: 0.7),
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
