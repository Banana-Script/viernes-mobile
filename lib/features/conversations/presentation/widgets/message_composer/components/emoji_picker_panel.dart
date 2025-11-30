import 'package:flutter/material.dart';
import '../../../../../../core/theme/viernes_colors.dart';
import '../../../../../../core/theme/viernes_spacing.dart';

/// Emoji Picker Panel Component
///
/// Grid of emojis that can be selected and inserted into the message.
class EmojiPickerPanel extends StatelessWidget {
  final void Function(String emoji)? onEmojiSelected;
  final VoidCallback? onClose;

  const EmojiPickerPanel({
    super.key,
    this.onEmojiSelected,
    this.onClose,
  });

  /// Curated list of common emojis
  static const List<String> emojis = [
    // Smileys
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇',
    '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚',
    '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🤩',
    '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '😣', '😖',
    '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯',
    // Gestures & People
    '👍', '👎', '👋', '🙏', '💪', '🤝', '👏', '✌️', '🤞', '🤟',
    // Hearts & Symbols
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '💔', '❣️',
    '🔥', '✨', '🎉', '💯', '✅', '❌', '⭐', '🌟', '💫', '🎊',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: ViernesSpacing.md),
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, isDark),
          // Emoji Grid
          Expanded(
            child: _buildEmojiGrid(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_emotions,
            size: 20,
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Text(
            'Emojis',
            style: TextStyle(
              color: ViernesColors.getTextColor(isDark),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close,
              size: 20,
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(ViernesSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return _EmojiButton(
          emoji: emoji,
          onTap: () => onEmojiSelected?.call(emoji),
        );
      },
    );
  }
}

/// Individual emoji button
class _EmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback? onTap;

  const _EmojiButton({
    required this.emoji,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
