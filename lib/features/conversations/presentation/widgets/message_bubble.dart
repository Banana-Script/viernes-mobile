import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../domain/entities/message_entity.dart';

/// Message Bubble Widget
///
/// Displays a message bubble styled for customer (left) or agent (right).
class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isDark;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomer = message.isCustomerMessage;
    final isAgent = message.isAgentMessage;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: ViernesSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment:
            isCustomer ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isCustomer) _buildAvatar(isCustomer),
          if (isCustomer) const SizedBox(width: 12),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: _getBubbleColor(isCustomer, isDark),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(6),
                  topRight: const Radius.circular(6),
                  bottomLeft: Radius.circular(isCustomer ? 6 : 0),
                  bottomRight: Radius.circular(isCustomer ? 0 : 6),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAgent && message.agentName != null) ...[
                    Text(
                      message.agentName!,
                      style: ViernesTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black.withValues(alpha: 0.75),
                        letterSpacing: 0.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (message.hasText)
                    Text(
                      message.text!,
                      style: ViernesTextStyles.bodyText.copyWith(
                        color: isCustomer
                            ? Colors.white
                            : ViernesColors.getTextColor(isDark),
                        height: 1.5,
                        letterSpacing: 0.15,
                      ),
                    ),
                  if (message.hasMedia) _buildMediaPreview(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: ViernesTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: isCustomer
                              ? Colors.white.withValues(alpha: 0.7)
                              : ViernesColors.getTextColor(isDark)
                                  .withValues(alpha: 0.5),
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (isAgent && message.status != null) ...[
                        const SizedBox(width: 4),
                        _buildReadReceipt(message.status!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isAgent) const SizedBox(width: 12),
          if (isAgent) _buildAvatar(isCustomer),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isCustomer) {
    if (isCustomer) {
      // Customer avatar - primary at 10% opacity with person icon
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ViernesColors.primary.withValues(alpha: 0.1), // rgba(55, 65, 81, 0.1)
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.person,
            size: 20,
            color: ViernesColors.primary,
          ),
        ),
      );
    } else {
      // Bot/Agent avatar - yellow at opacity with bot icon
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFFfde047).withValues(alpha: 0.1) // yellow-300 at 10%
              : const Color(0xFFfef9c3).withValues(alpha: 0.5), // yellow-100 at 50%
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.smart_toy,
            size: 28,
            color: Colors.black,
          ),
        ),
      );
    }
  }

  Widget _buildMediaPreview() {
    if (message.isImage) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.media!,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                color: Colors.grey.withValues(alpha: 0.3),
                child: const Icon(Icons.broken_image, size: 48),
              );
            },
          ),
        ),
      );
    } else if (message.hasFile) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(),
              size: 20,
              color: message.isAgentMessage
                  ? Colors.black.withValues(alpha: 0.8)
                  : ViernesColors.accent,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message.fileName ?? 'File',
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: message.isAgentMessage
                      ? Colors.black
                      : ViernesColors.accent,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildReadReceipt(String status) {
    IconData icon;
    Color color;
    bool isRead = status.toLowerCase() == 'read';

    switch (status.toLowerCase()) {
      case 'sent':
        icon = Icons.check;
        color = Colors.black.withValues(alpha: 0.5);
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.black.withValues(alpha: 0.6);
        break;
      case 'read':
        icon = Icons.done_all;
        color = ViernesColors.accent;
        break;
      default:
        icon = Icons.schedule;
        color = Colors.black.withValues(alpha: 0.4);
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isRead
            ? ViernesColors.accent.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  IconData _getFileIcon() {
    if (message.isDocument) return Icons.description;
    if (message.isVideo) return Icons.video_file;
    if (message.isAudio) return Icons.audio_file;
    return Icons.attach_file;
  }

  Color _getBubbleColor(bool isCustomer, bool isDark) {
    if (isCustomer) {
      // User messages: solid primary color
      return ViernesColors.primary; // #374151 solid
    }
    // Agent messages: black at 10% opacity (light mode) or gray-800 (dark mode)
    return isDark
        ? const Color(0xFF1f2937) // #1f2937 (gray-800)
        : const Color(0x1A000000); // Black at 10% opacity = rgba(0, 0, 0, 0.1)
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
