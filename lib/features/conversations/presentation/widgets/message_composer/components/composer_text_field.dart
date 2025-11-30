import 'package:flutter/material.dart';
import '../../../../../../core/theme/viernes_colors.dart';
import '../../../../../../core/theme/viernes_text_styles.dart';

/// Composer Text Field Component
///
/// Expandable text input for message composition.
/// Supports multiline input with auto-expanding height.
class ComposerTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmit;

  const ComposerTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    this.hintText = 'Type a message...',
    this.onChanged,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: onChanged,
      style: ViernesTextStyles.bodyText.copyWith(
        color: ViernesColors.getTextColor(isDark),
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
      ),
    );
  }
}
