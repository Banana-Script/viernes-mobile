import 'package:flutter/material.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_text_styles.dart';
import '../../core/theme/viernes_spacing.dart';
import 'viernes_glassmorphism_card.dart';
import 'viernes_button.dart';

/// Unsaved Changes Dialog
///
/// Shows a confirmation dialog when user tries to leave a form with unsaved changes.
/// Used in both Add and Edit customer forms.
///
/// Returns:
/// - `true` if user chooses to discard changes
/// - `false` if user chooses to stay
class UnsavedChangesDialog extends StatelessWidget {
  final bool isDark;

  const UnsavedChangesDialog({
    super.key,
    required this.isDark,
  });

  /// Show the dialog and return the user's choice
  static Future<bool> show(BuildContext context, bool isDark) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UnsavedChangesDialog(isDark: isDark),
    );
    return result ?? false; // Default to not discarding
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ViernesGlassmorphismCard(
        borderRadius: ViernesSpacing.radius24,
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(ViernesSpacing.md),
              decoration: BoxDecoration(
                color: ViernesColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                size: 48,
                color: ViernesColors.warning,
              ),
            ),
            const SizedBox(height: ViernesSpacing.md),
            // Title
            Text(
              'Unsaved Changes',
              style: ViernesTextStyles.h5.copyWith(
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.sm),
            // Message
            Text(
              'You have unsaved changes. Are you sure you want to leave?',
              style: ViernesTextStyles.bodyText.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.lg),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ViernesButton.outline(
                    text: 'Stay',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.sm),
                Expanded(
                  child: ViernesButton.danger(
                    text: 'Discard',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
