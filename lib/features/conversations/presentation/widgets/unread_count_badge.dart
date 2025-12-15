import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import 'conversation_card.dart';

/// Unread Count Badge Widget
///
/// Displays unread message count in a pill with priority-based styling.
/// - `myUnread`: Larger cyan badge with glow
/// - `unassignedUnread`: Yellow badge
/// - `normal`: Cyan badge (default)
class UnreadCountBadge extends StatelessWidget {
  final int count;
  final double? fontSize;
  final double? minWidth;
  final ConversationPriority? priority;

  const UnreadCountBadge({
    super.key,
    required this.count,
    this.fontSize,
    this.minWidth,
    this.priority,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMyUnread = priority == ConversationPriority.myUnread;
    final isUnassignedUnread = priority == ConversationPriority.unassignedUnread;

    // Dynamic sizing based on priority
    final effectiveMinWidth = minWidth ?? (isMyUnread ? 26 : 24);
    final effectiveMinHeight = isMyUnread ? 22.0 : 20.0;
    final effectiveFontSize = fontSize ?? (isMyUnread ? 12 : 11);

    // Color based on priority
    final backgroundColor = isUnassignedUnread
        ? ViernesColors.secondary
        : ViernesColors.accent;

    return Container(
      constraints: BoxConstraints(
        minWidth: effectiveMinWidth.toDouble(),
        minHeight: effectiveMinHeight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
        boxShadow: isMyUnread && isDark
            ? [
                BoxShadow(
                  color: ViernesColors.accent.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.black,
          fontSize: effectiveFontSize.toDouble(),
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
