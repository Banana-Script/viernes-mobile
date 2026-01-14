import 'package:flutter/material.dart';
import '../../../../../gen_l10n/app_localizations.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Internal Note Modal
///
/// Modal dialog for creating or editing an internal note.
class InternalNoteModal extends StatefulWidget {
  final String title;
  final String? initialContent;

  const InternalNoteModal({
    super.key,
    required this.title,
    this.initialContent,
  });

  /// Show the modal and return the note content or null if cancelled
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? initialContent,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InternalNoteModal(
        title: title,
        initialContent: initialContent,
      ),
    );
  }

  @override
  State<InternalNoteModal> createState() => _InternalNoteModalState();
}

class _InternalNoteModalState extends State<InternalNoteModal> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() == true) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.note_alt_outlined,
            color: ViernesColors.warning,
            size: 24,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Expanded(
            child: Text(
              widget.title,
              style: ViernesTextStyles.h6.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.noteVisibleToAgents ?? 'This note will only be visible to agents',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: ViernesSpacing.md),
            TextFormField(
              controller: _controller,
              maxLines: 5,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n?.writeNoteHint ?? 'Write your note here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ViernesColors.getBorderColor(isDark),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ViernesColors.getBorderColor(isDark),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ViernesColors.warning,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ViernesColors.danger,
                  ),
                ),
                filled: true,
                fillColor: isDark
                    ? ViernesColors.primary.withValues(alpha: 0.1)
                    : Colors.white,
              ),
              style: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n?.pleaseWriteNote ?? 'Please write a note';
                }
                if (value.trim().length < 3) {
                  return l10n?.noteTooShort ?? 'Note must be at least 3 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n?.cancel ?? 'Cancel',
            style: ViernesTextStyles.buttonMedium.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: ViernesColors.warning,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.initialContent != null
                ? (l10n?.update ?? 'Update')
                : (l10n?.save ?? 'Save'),
          ),
        ),
      ],
    );
  }
}
