import 'package:flutter/material.dart';
import '../../../../../../core/theme/viernes_colors.dart';
import '../../../../../../core/theme/viernes_spacing.dart';
import '../../../../../../core/theme/viernes_text_styles.dart';

/// Attachment Bottom Sheet Component
///
/// WhatsApp-style bottom sheet with attachment options.
class AttachmentBottomSheet extends StatelessWidget {
  final VoidCallback? onQuickReply;
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;
  final VoidCallback? onDocument;

  const AttachmentBottomSheet({
    super.key,
    this.onQuickReply,
    this.onCamera,
    this.onGallery,
    this.onDocument,
  });

  /// Shows the attachment bottom sheet and returns when dismissed
  static Future<void> show({
    required BuildContext context,
    VoidCallback? onQuickReply,
    VoidCallback? onCamera,
    VoidCallback? onGallery,
    VoidCallback? onDocument,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentBottomSheet(
        onQuickReply: onQuickReply,
        onCamera: onCamera,
        onGallery: onGallery,
        onDocument: onDocument,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ViernesSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: ViernesSpacing.sm),
              decoration: BoxDecoration(
                color: ViernesColors.getBorderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: ViernesSpacing.md),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ViernesSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'Opciones',
                    style: ViernesTextStyles.h6.copyWith(
                      color: ViernesColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ViernesSpacing.md),
            // Options
            _AttachmentOption(
              icon: Icons.flash_on_rounded,
              iconColor: ViernesColors.warning,
              label: 'Quick Replies',
              subtitle: 'Respuestas rápidas predefinidas',
              onTap: () {
                Navigator.pop(context);
                onQuickReply?.call();
              },
            ),
            _AttachmentOption(
              icon: Icons.camera_alt_rounded,
              iconColor: ViernesColors.info,
              label: 'Tomar foto',
              subtitle: 'Usar la cámara del dispositivo',
              onTap: () {
                Navigator.pop(context);
                onCamera?.call();
              },
            ),
            _AttachmentOption(
              icon: Icons.photo_library_rounded,
              iconColor: ViernesColors.success,
              label: 'Galería',
              subtitle: 'Seleccionar imagen existente',
              onTap: () {
                Navigator.pop(context);
                onGallery?.call();
              },
            ),
            _AttachmentOption(
              icon: Icons.insert_drive_file_rounded,
              iconColor: ViernesColors.primary,
              label: 'Documento',
              subtitle: 'PDF, Word, Excel y más',
              onTap: () {
                Navigator.pop(context);
                onDocument?.call();
              },
            ),
            const SizedBox(height: ViernesSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Individual attachment option tile
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _AttachmentOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.lg,
            vertical: ViernesSpacing.md,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: ViernesSpacing.md),
              // Label and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: ViernesTextStyles.bodyText.copyWith(
                        color: ViernesColors.getTextColor(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: ViernesTextStyles.caption.copyWith(
                        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
