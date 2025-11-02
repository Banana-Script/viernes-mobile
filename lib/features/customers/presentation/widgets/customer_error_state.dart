import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';

/// Customer Error State Widget
///
/// Displays an error state with retry functionality.
/// Features:
/// - Error icon with gradient background
/// - Error message
/// - Retry button
/// - Glassmorphism design
class CustomerErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomerErrorState({
    super.key,
    this.message = 'Failed to load customers',
    this.onRetry,
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
              // Error icon with gradient background
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ViernesColors.danger.withValues(alpha: 0.2),
                      ViernesColors.warning.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: ViernesColors.danger,
                ),
              ),
              const SizedBox(height: ViernesSpacing.lg),

              // Error title
              Text(
                'Oops!',
                style: ViernesTextStyles.h3.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ViernesSpacing.sm),

              // Error message
              Text(
                message,
                style: ViernesTextStyles.bodyText.copyWith(
                  color: ViernesColors.getTextColor(isDark)
                      .withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),

              // Retry button
              if (onRetry != null) ...[
                const SizedBox(height: ViernesSpacing.lg),
                ViernesGradientButton(
                  text: 'Retry',
                  onPressed: onRetry,
                  isLoading: false,
                  width: 200,
                  borderRadius: ViernesSpacing.radius14,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
