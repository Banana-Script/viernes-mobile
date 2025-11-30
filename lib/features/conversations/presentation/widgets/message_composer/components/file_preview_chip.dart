import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/viernes_colors.dart';
import '../../../../../../core/theme/viernes_spacing.dart';
import '../../../../../../core/theme/viernes_text_styles.dart';
import '../models/attachment_model.dart';

/// File Preview Chip Component
///
/// Displays a single file attachment with thumbnail, name, size, and remove button.
class FilePreviewChip extends StatelessWidget {
  final AttachmentModel attachment;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;

  const FilePreviewChip({
    super.key,
    required this.attachment,
    this.onRemove,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1b2e4b) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
        border: attachment.hasError
            ? Border.all(color: ViernesColors.danger.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File icon or thumbnail
          _buildFilePreview(isDark),
          const SizedBox(width: ViernesSpacing.xs),
          // File info
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.fileName,
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                _buildStatusRow(isDark),
              ],
            ),
          ),
          const SizedBox(width: ViernesSpacing.xs),
          // Action button (remove or retry)
          _buildActionButton(isDark),
        ],
      ),
    );
  }

  Widget _buildFilePreview(bool isDark) {
    if (attachment.isImage && attachment.path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Image.file(
            File(attachment.path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFileIcon(isDark),
          ),
        ),
      );
    }
    return _buildFileIcon(isDark);
  }

  Widget _buildFileIcon(bool isDark) {
    IconData icon;
    Color color;

    switch (attachment.extension) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = ViernesColors.danger;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = ViernesColors.info;
        break;
      case 'xls':
      case 'xlsx':
        icon = Icons.table_chart;
        color = ViernesColors.success;
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow;
        color = ViernesColors.warning;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        color = ViernesColors.primaryLight;
        break;
      default:
        icon = attachment.isImage ? Icons.image : Icons.insert_drive_file;
        color = ViernesColors.getTextColor(isDark);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildStatusRow(bool isDark) {
    if (attachment.isUploading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: LinearProgressIndicator(
              value: attachment.uploadProgress,
              minHeight: 3,
              backgroundColor: ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? ViernesColors.accent : ViernesColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(attachment.uploadProgress * 100).toInt()}%',
            style: ViernesTextStyles.caption.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      );
    }

    if (attachment.hasError) {
      return Text(
        'Error',
        style: ViernesTextStyles.caption.copyWith(
          color: ViernesColors.danger,
          fontSize: 10,
        ),
      );
    }

    return Text(
      attachment.formattedSize,
      style: ViernesTextStyles.caption.copyWith(
        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
        fontSize: 10,
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    if (attachment.hasError && onRetry != null) {
      return GestureDetector(
        onTap: onRetry,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: ViernesColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.refresh,
            size: 14,
            color: ViernesColors.warning,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onRemove,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: ViernesColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.close,
          size: 14,
          color: ViernesColors.danger,
        ),
      ),
    );
  }
}
