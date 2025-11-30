import 'package:flutter/material.dart';
import '../../../../../../core/theme/viernes_colors.dart';
import '../../../../../../core/theme/viernes_spacing.dart';
import '../models/attachment_model.dart';
import 'file_preview_chip.dart';

/// File Preview Bar Component
///
/// Horizontal scrollable list of file attachments above the message input.
class FilePreviewBar extends StatelessWidget {
  final List<AttachmentModel> attachments;
  final void Function(AttachmentModel)? onRemove;
  final void Function(AttachmentModel)? onRetry;

  const FilePreviewBar({
    super.key,
    required this.attachments,
    this.onRemove,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.md,
          vertical: ViernesSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: attachments.length,
          separatorBuilder: (_, __) => const SizedBox(width: ViernesSpacing.sm),
          itemBuilder: (context, index) {
            final attachment = attachments[index];
            return FilePreviewChip(
              attachment: attachment,
              onRemove: onRemove != null ? () => onRemove!(attachment) : null,
              onRetry: onRetry != null && attachment.hasError
                  ? () => onRetry!(attachment)
                  : null,
            );
          },
        ),
      ),
    );
  }
}
