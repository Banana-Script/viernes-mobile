import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Delete Note Dialog
///
/// Confirmation dialog for deleting an internal note.
class DeleteNoteDialog extends StatelessWidget {
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const DeleteNoteDialog({
    super.key,
    this.onConfirm,
    this.onCancel,
  });

  /// Show the dialog and return true if confirmed
  static Future<bool?> show({required BuildContext context}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteNoteDialog(
        onConfirm: () => Navigator.pop(_, true),
        onCancel: () => Navigator.pop(_, false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.delete_outline,
            color: ViernesColors.danger,
            size: 24,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Text(
            'Eliminar nota',
            style: ViernesTextStyles.h6.copyWith(
              color: ViernesColors.getTextColor(isDark),
            ),
          ),
        ],
      ),
      content: Text(
        '¿Estás seguro de que deseas eliminar esta nota? Esta acción no se puede deshacer.',
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancelar',
            style: ViernesTextStyles.buttonMedium.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: ViernesColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
