import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Complete Conversation Dialog
///
/// Confirmation dialog for completing a conversation as successful or unsuccessful.
class CompleteConversationDialog extends StatelessWidget {
  final bool isSuccessful;
  final bool isLoading;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CompleteConversationDialog({
    super.key,
    required this.isSuccessful,
    this.isLoading = false,
    this.onConfirm,
    this.onCancel,
  });

  /// Show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required bool isSuccessful,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => CompleteConversationDialog(
        isSuccessful: isSuccessful,
        isLoading: isLoading,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = isSuccessful
        ? 'Completar conversación exitosamente'
        : 'Completar conversación sin éxito';

    final message = isSuccessful
        ? '¿Estás seguro de que deseas marcar esta conversación como completada exitosamente? Esta acción no se puede deshacer.'
        : '¿Estás seguro de que deseas marcar esta conversación como completada sin éxito? Esta acción no se puede deshacer.';

    final confirmText = isSuccessful ? 'Completar' : 'Completar sin éxito';
    final confirmColor = isSuccessful ? ViernesColors.success : ViernesColors.danger;

    return AlertDialog(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            isSuccessful ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: confirmColor,
            size: 24,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: ViernesTextStyles.h6.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : onCancel,
          child: Text(
            'Cancelar',
            style: ViernesTextStyles.buttonMedium.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(confirmText),
        ),
      ],
    );
  }
}
