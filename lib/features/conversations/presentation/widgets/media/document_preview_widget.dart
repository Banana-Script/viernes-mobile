import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';

/// Document Preview Widget
///
/// Displays a document preview with icon, filename, and download button.
/// Supports various document types (PDF, DOC, XLS, etc.).
class DocumentPreviewWidget extends StatelessWidget {
  final String url;
  final String? fileName;
  final String? fileSize;

  const DocumentPreviewWidget({
    super.key,
    required this.url,
    this.fileName,
    this.fileSize,
  });

  /// Get icon based on file extension
  IconData _getDocumentIcon() {
    final extension = _getFileExtension()?.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.article;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Get color based on file extension
  Color _getDocumentColor() {
    final extension = _getFileExtension()?.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red.shade600;
      case 'doc':
      case 'docx':
        return Colors.blue.shade600;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade600;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade600;
      case 'txt':
        return Colors.grey.shade600;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.amber.shade700;
      default:
        return ViernesColors.primary;
    }
  }

  /// Extract file extension from URL or filename
  String? _getFileExtension() {
    final name = fileName ?? _extractFileName();
    if (name == null) return null;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1);
    }
    return null;
  }

  /// Extract filename from URL
  String? _extractFileName() {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return Uri.decodeComponent(pathSegments.last);
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Get display name for the document
  String _getDisplayName() {
    final name = fileName ?? _extractFileName();
    if (name != null && name.isNotEmpty) {
      // Truncate long names
      if (name.length > 30) {
        final ext = _getFileExtension();
        if (ext != null) {
          return '${name.substring(0, 25)}....$ext';
        }
        return '${name.substring(0, 28)}...';
      }
      return name;
    }
    return 'Document';
  }

  Future<void> _openDocument() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final documentColor = _getDocumentColor();

    return GestureDetector(
      onTap: _openDocument,
      child: Container(
        padding: const EdgeInsets.all(ViernesSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? ViernesColors.panelDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ViernesColors.getBorderColor(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Document icon with colored background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: documentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getDocumentIcon(),
                color: documentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),

            // Document info
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getDisplayName(),
                    style: ViernesTextStyles.bodyText.copyWith(
                      color: ViernesColors.getTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getFileExtension()?.toUpperCase() ?? 'FILE',
                        style: ViernesTextStyles.caption.copyWith(
                          color: documentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                      if (fileSize != null) ...[
                        Text(
                          ' • ',
                          style: ViernesTextStyles.caption.copyWith(
                            color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
                          ),
                        ),
                        Text(
                          fileSize!,
                          style: ViernesTextStyles.caption.copyWith(
                            color: ViernesColors.getTextColor(isDark).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: ViernesSpacing.sm),

            // Download button
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ViernesColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download,
                color: ViernesColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
