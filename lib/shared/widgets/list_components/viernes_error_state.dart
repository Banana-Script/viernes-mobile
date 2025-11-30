import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../viernes_glassmorphism_card.dart';
import '../viernes_gradient_button.dart';

/// Viernes Error State Widget
///
/// Displays an error state with optional retry functionality.
///
/// Features:
/// - Error icon with gradient background
/// - Customizable title and message
/// - Optional retry button
/// - Glassmorphism design
/// - Theme-aware colors (light/dark mode)
class ViernesErrorState extends StatelessWidget {
  /// Error title (default: 'Oops!')
  final String title;

  /// Error message describing what went wrong
  final String message;

  /// Retry button callback (button hidden if null)
  final VoidCallback? onRetry;

  /// Retry button label (default: 'Retry')
  final String retryLabel;

  const ViernesErrorState({
    super.key,
    this.title = 'Oops!',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
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
                title,
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
                  color:
                      ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),

              // Retry button
              if (onRetry != null) ...[
                const SizedBox(height: ViernesSpacing.lg),
                ViernesGradientButton(
                  text: retryLabel,
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
