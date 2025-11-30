import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../customers/domain/entities/conversation_entity.dart';
import '../providers/conversation_provider.dart';
import 'status_badge.dart';
import 'priority_badge.dart';
import 'tags_badge.dart';
import 'unread_count_badge.dart';

/// Conversation Card Widget
///
/// Displays a conversation in the list following the customer card design.
/// Features:
/// - Vertical column layout with dividers
/// - Customer avatar and name
/// - Time ago in top-right
/// - Channel and agent information
/// - Status, priority, tags, and unread count badges
/// - Message preview with icon (2 lines max)
/// - Lazy loads first message when card is built
///
/// Design follows Viernes glassmorphism aesthetic matching customer cards.
class ConversationCard extends StatefulWidget {
  final ConversationEntity conversation;
  final VoidCallback? onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    this.onTap,
  });

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard> {
  @override
  void initState() {
    super.initState();
    // Lazy load first message when card is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if widget is still mounted before accessing context
      if (mounted) {
        final provider = Provider.of<ConversationProvider>(context, listen: false);
        provider.loadFirstMessage(widget.conversation.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = ViernesColors.getTextColor(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
      child: ViernesGlassmorphismCard(
        borderRadius: ViernesSpacing.radiusXxl,
        padding: const EdgeInsets.all(ViernesSpacing.md),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar, Name, and Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with gradient
                _buildAvatar(context),
                const SizedBox(width: ViernesSpacing.space3),

                // Name and channel/agent info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer name with time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.conversation.user?.fullname ?? 'Unknown Customer',
                              style: ViernesTextStyles.h6.copyWith(
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: ViernesSpacing.xs),
                          Text(
                            _formatTimeAgo(widget.conversation.updatedAt),
                            style: ViernesTextStyles.bodySmall.copyWith(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Channel and Agent info
                      Row(
                        children: [
                          // Channel icon
                          Icon(
                            _getChannelIcon(),
                            size: 12,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),

                          // Channel name
                          Text(
                            _getChannelName(),
                            style: ViernesTextStyles.bodySmall.copyWith(
                              color: textColor.withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),

                          // Separator
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: ViernesTextStyles.bodySmall.copyWith(
                                color: textColor.withValues(alpha: 0.4),
                              ),
                            ),
                          ),

                          // Agent icon
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),

                          // Agent name
                          Expanded(
                            child: Text(
                              _getAgentName(),
                              style: ViernesTextStyles.bodySmall.copyWith(
                                color: textColor.withValues(alpha: 0.6),
                                fontStyle: widget.conversation.agent == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Badges row
            const SizedBox(height: ViernesSpacing.sm),
            Wrap(
              spacing: ViernesSpacing.xs,
              runSpacing: ViernesSpacing.xs,
              children: [
                if (widget.conversation.status != null)
                  StatusBadge(status: widget.conversation.status!.description),
                if (widget.conversation.priority != null)
                  PriorityBadge(priority: widget.conversation.priority),
                if (widget.conversation.tags.isNotEmpty)
                  TagsBadge(tags: widget.conversation.tags),
                if (widget.conversation.unreaded > 0)
                  UnreadCountBadge(count: widget.conversation.unreaded),
              ],
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Divider
            Container(
              height: 1,
              color: textColor.withValues(alpha: 0.1),
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Message preview with icon
            Consumer<ConversationProvider>(
              builder: (context, provider, child) {
                final firstMessage = provider.getFirstMessage(widget.conversation.id);
                final isLoading = provider.isLoadingFirstMessage(widget.conversation.id);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: ViernesSpacing.xs),
                    Expanded(
                      child: Text(
                        isLoading
                            ? 'Loading...'
                            : (firstMessage ?? _getMessagePreview()),
                        style: ViernesTextStyles.bodySmall.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                          fontStyle: isLoading ? FontStyle.italic : FontStyle.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final fullname = widget.conversation.user?.fullname ?? '';
    final initial = fullname.isNotEmpty ? fullname[0].toUpperCase() : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ViernesColors.secondary.withValues(alpha: 0.8),
            ViernesColors.accent.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? ViernesColors.accent.withValues(alpha: 0.3)
              : ViernesColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  IconData _getChannelIcon() {
    final instance = widget.conversation.user?.instance?.toLowerCase();

    if (instance == null) {
      return Icons.chat_outlined;
    }

    if (instance.contains('whatsapp')) {
      return Icons.phone_android;
    } else if (instance.contains('instagram')) {
      return Icons.camera_alt_outlined;
    } else if (instance.contains('facebook') || instance.contains('messenger')) {
      return Icons.messenger_outline;
    } else if (instance.contains('email') || instance.contains('mail')) {
      return Icons.email_outlined;
    } else if (instance.contains('web')) {
      return Icons.language;
    } else if (instance.contains('sms')) {
      return Icons.sms_outlined;
    }

    return Icons.chat_outlined;
  }

  String _getChannelName() {
    final instance = widget.conversation.user?.instance;

    if (instance == null || instance.isEmpty) {
      return widget.conversation.type == ConversationType.call ? 'Call' : 'Chat';
    }

    // Extract channel name from instance (e.g., "whatsapp_business" -> "WhatsApp")
    final lowerInstance = instance.toLowerCase();

    if (lowerInstance.contains('whatsapp')) {
      return 'WhatsApp';
    } else if (lowerInstance.contains('instagram')) {
      return 'Instagram';
    } else if (lowerInstance.contains('messenger')) {
      return 'Messenger';
    } else if (lowerInstance.contains('facebook')) {
      return 'Facebook';
    } else if (lowerInstance.contains('email') || lowerInstance.contains('mail')) {
      return 'Email';
    } else if (lowerInstance.contains('web')) {
      return 'Web';
    } else if (lowerInstance.contains('sms')) {
      return 'SMS';
    }

    // Capitalize first letter of instance as fallback
    if (instance.isEmpty) return 'Unknown';
    return instance[0].toUpperCase() +
           (instance.length > 1 ? instance.substring(1).toLowerCase() : '');
  }

  String _getAgentName() {
    // Check if there's an agent assigned
    if (widget.conversation.agent != null) {
      return widget.conversation.agent!.fullname;
    }

    // Check assigns array as fallback
    if (widget.conversation.assigns.isNotEmpty) {
      return widget.conversation.assigns.first.user.fullname;
    }

    return 'Viernes';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String _getMessagePreview() {
    // Fallback message when first message hasn't loaded yet
    // Check memory field first as a backup
    if (widget.conversation.memory != null && widget.conversation.memory!.isNotEmpty) {
      return widget.conversation.memory!;
    }

    if (widget.conversation.type == ConversationType.call) {
      return 'Phone call conversation';
    }

    return 'No messages yet';
  }
}
