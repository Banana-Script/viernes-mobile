import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../customers/domain/entities/conversation_entity.dart';

/// Tags Badge Widget
///
/// Displays conversation tags following the web frontend pattern:
/// - Shows first 2 tags as badges
/// - Shows "+N" count for remaining tags
/// - Tapping "+N" opens a dialog with all tags
class TagsBadge extends StatelessWidget {
  final List<ConversationTag> tags;

  const TagsBadge({
    super.key,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Show first 2 tags
        ...tags.take(2).map((tag) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _TagChip(tag: tag, isDark: isDark),
            )),

        // Show "+N" count for remaining tags
        if (tags.length > 2)
          GestureDetector(
            onTap: () => _showAllTagsDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+${tags.length - 2}',
                style: ViernesTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ViernesColors.getTextColor(isDark),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAllTagsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ViernesColors.getControlBackground(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(ViernesSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Tags (${tags.length})',
                    style: ViernesTextStyles.h6.copyWith(
                      color: ViernesColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: ViernesColors.getTextColor(isDark),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: ViernesSpacing.sm),

              // All tags in a wrap
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: tags.map((tag) => _TagChip(
                      tag: tag,
                      isDark: isDark,
                      showTooltip: true,
                    )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual Tag Chip
class _TagChip extends StatelessWidget {
  final ConversationTag tag;
  final bool isDark;
  final bool showTooltip;

  const _TagChip({
    required this.tag,
    required this.isDark,
    this.showTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: ViernesColors.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag.tagName,
        style: ViernesTextStyles.bodySmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );

    if (showTooltip && tag.description.isNotEmpty) {
      return Tooltip(
        message: '${tag.tagName}: ${tag.description}',
        textStyle: ViernesTextStyles.bodySmall.copyWith(
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: chip,
      );
    }

    return chip;
  }
}
