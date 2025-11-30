import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';
import '../../../domain/entities/internal_note_entity.dart';

/// Internal Note Card
///
/// Displays a single internal note with edit/delete options.
class InternalNoteCard extends StatelessWidget {
  final InternalNoteEntity note;
  final bool canEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InternalNoteCard({
    super.key,
    required this.note,
    this.canEdit = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? ViernesColors.getControlBackground(isDark).withValues(alpha: 0.5)
            : ViernesColors.warningLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ViernesColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with agent name and actions
          Row(
            children: [
              // Agent avatar
              CircleAvatar(
                radius: 14,
                backgroundColor: ViernesColors.primary.withValues(alpha: 0.2),
                child: Text(
                  _getInitials(note.agentName),
                  style: ViernesTextStyles.label.copyWith(
                    color: ViernesColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: ViernesSpacing.sm),
              // Agent name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.agentName,
                      style: ViernesTextStyles.label.copyWith(
                        color: ViernesColors.getTextColor(isDark),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(note.createdAt),
                      style: ViernesTextStyles.bodySmall.copyWith(
                        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Edited indicator
              if (note.wasEdited)
                Padding(
                  padding: const EdgeInsets.only(right: ViernesSpacing.sm),
                  child: Text(
                    '(editada)',
                    style: ViernesTextStyles.bodySmall.copyWith(
                      color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
                ),
              // Actions (only if can edit)
              if (canEdit) ...[
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(ViernesSpacing.xs),
                  tooltip: 'Editar',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: ViernesColors.danger.withValues(alpha: 0.7),
                  ),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(ViernesSpacing.xs),
                  tooltip: 'Eliminar',
                ),
              ],
            ],
          ),
          const SizedBox(height: ViernesSpacing.sm),
          // Note content
          Text(
            note.content,
            style: ViernesTextStyles.bodyText.copyWith(
              color: ViernesColors.getTextColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inHours < 1) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inDays < 1) {
      return 'Hace ${diff.inHours} h';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
