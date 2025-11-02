import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../../shared/widgets/viernes_button.dart';

/// Delete Customer Dialog
///
/// Confirmation dialog for deleting a customer.
/// Features:
/// - Warning icon with red theme
/// - Customer name display
/// - Cancel and Delete buttons
/// - Loading state during deletion
///
/// Usage:
/// ```dart
/// final confirmed = await DeleteCustomerDialog.show(
///   context,
///   customerName: 'John Doe',
///   isDark: isDark,
/// );
/// if (confirmed) {
///   // Proceed with deletion
/// }
/// ```
class DeleteCustomerDialog extends StatefulWidget {
  final String customerName;
  final bool isDark;

  const DeleteCustomerDialog({
    super.key,
    required this.customerName,
    required this.isDark,
  });

  /// Show the dialog and return true if user confirms deletion
  static Future<bool> show(
    BuildContext context, {
    required String customerName,
    required bool isDark,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteCustomerDialog(
        customerName: customerName,
        isDark: isDark,
      ),
    );
    return result ?? false;
  }

  @override
  State<DeleteCustomerDialog> createState() => _DeleteCustomerDialogState();
}

class _DeleteCustomerDialogState extends State<DeleteCustomerDialog> {
  bool _isDeleting = false;

  void _onDelete() {
    setState(() => _isDeleting = true);
    // Small delay to show loading state
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
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
                color: ViernesColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                size: 48,
                color: ViernesColors.danger,
              ),
            ),
            const SizedBox(height: ViernesSpacing.md),
            // Title
            Text(
              'Delete Customer?',
              style: ViernesTextStyles.h5.copyWith(
                color: widget.isDark ? ViernesColors.textDark : ViernesColors.textLight,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.sm),
            // Message
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: ViernesTextStyles.bodyText.copyWith(
                  color: (widget.isDark ? ViernesColors.textDark : ViernesColors.textLight)
                      .withValues(alpha: 0.8),
                ),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete '),
                  TextSpan(
                    text: widget.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
            ),
            const SizedBox(height: ViernesSpacing.xs),
            // Warning
            Text(
              'This action cannot be undone.',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.danger,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.lg),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ViernesButton.outline(
                    text: 'Cancel',
                    onPressed: _isDeleting ? null : () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.sm),
                Expanded(
                  child: ViernesButton.danger(
                    text: 'Delete',
                    isLoading: _isDeleting,
                    onPressed: _isDeleting ? null : _onDelete,
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
