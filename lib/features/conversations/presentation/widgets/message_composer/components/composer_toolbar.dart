import 'package:flutter/material.dart';
import '../../../../../../core/theme/viernes_colors.dart';
import '../../../../../../core/theme/viernes_spacing.dart';
import 'attachment_bottom_sheet.dart';

/// Composer Toolbar Component
///
/// Two buttons: emoji toggle and "+" that opens bottom sheet with attachment options.
class ComposerToolbar extends StatelessWidget {
  final bool isEmojiActive;
  final VoidCallback? onEmojiToggle;
  final VoidCallback? onQuickReplyToggle;
  final VoidCallback? onCameraPick;
  final VoidCallback? onImagePick;
  final VoidCallback? onDocumentPick;
  final bool enabled;

  const ComposerToolbar({
    super.key,
    this.isEmojiActive = false,
    this.onEmojiToggle,
    this.onQuickReplyToggle,
    this.onCameraPick,
    this.onImagePick,
    this.onDocumentPick,
    this.enabled = true,
  });

  void _showAttachmentSheet(BuildContext context) {
    AttachmentBottomSheet.show(
      context: context,
      onQuickReply: onQuickReplyToggle,
      onCamera: onCameraPick,
      onGallery: onImagePick,
      onDocument: onDocumentPick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji button
        _ComposerIconButton(
          icon: Icons.emoji_emotions_outlined,
          isActive: isEmojiActive,
          onTap: enabled ? onEmojiToggle : null,
        ),
        const SizedBox(width: ViernesSpacing.xs),
        // Attachment button (opens bottom sheet)
        _ComposerIconButton(
          icon: Icons.add,
          onTap: enabled ? () => _showAttachmentSheet(context) : null,
        ),
      ],
    );
  }
}

/// Individual icon button for the toolbar
class _ComposerIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _ComposerIconButton({
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onTap != null;

    final activeColor = isDark ? ViernesColors.accent : ViernesColors.primary;
    final inactiveColor = ViernesColors.getTextColor(isDark).withValues(alpha: 0.6);
    final disabledColor = ViernesColors.getTextColor(isDark).withValues(alpha: 0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isEnabled
                  ? (isActive ? activeColor : inactiveColor)
                  : disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
