import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customers/domain/entities/conversation_entity.dart';
import '../providers/conversation_provider.dart';
import 'status_badge.dart';
import 'priority_badge.dart';
import 'tags_badge.dart';
import 'unread_count_badge.dart';

/// Visual priority for conversation cards
/// Determines the visual emphasis based on unread status and assignment
enum ConversationPriority {
  /// Assigned to current user + has unread messages
  /// Visual: Cyan 4px border + glow effect
  myUnread,

  /// Not assigned (or assigned to other) + has unread messages
  /// Visual: Yellow 3px border
  unassignedUnread,

  /// No unread messages (read)
  /// Visual: No special border
  normal,
}

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

class _ConversationCardState extends State<ConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Setup pulse animation for unread indicator
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Lazy load first message when card is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if widget is still mounted before accessing context
      if (mounted) {
        final provider = Provider.of<ConversationProvider>(context, listen: false);
        provider.loadFirstMessage(widget.conversation.id);

        // Start pulse animation if has unread assigned to me
        if (_getVisualPriority(context) == ConversationPriority.myUnread) {
          _pulseController.repeat(reverse: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Determines the visual priority of the conversation
  /// Based on unread count and assignment to current user
  ConversationPriority _getVisualPriority(BuildContext context) {
    // No unread messages = normal priority
    if (widget.conversation.unreaded <= 0) {
      return ConversationPriority.normal;
    }

    // Has unread messages - check if assigned to current user
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.databaseId;

    if (currentUserId == null) {
      // Can't determine assignment, treat as unassigned unread
      return ConversationPriority.unassignedUnread;
    }

    // Check if conversation is assigned to current user
    final agentId = widget.conversation.agentId ?? widget.conversation.agent?.id;
    final isAssignedToMe = agentId == currentUserId;

    if (isAssignedToMe) {
      return ConversationPriority.myUnread;
    }

    return ConversationPriority.unassignedUnread;
  }

  /// Get border color based on visual priority
  Color? _getBorderColor(ConversationPriority priority) {
    switch (priority) {
      case ConversationPriority.myUnread:
        return ViernesColors.accent; // Cyan
      case ConversationPriority.unassignedUnread:
        return ViernesColors.secondary; // Yellow
      case ConversationPriority.normal:
        return null;
    }
  }

  /// Get border width based on visual priority
  double _getBorderWidth(ConversationPriority priority) {
    switch (priority) {
      case ConversationPriority.myUnread:
        return 4.0;
      case ConversationPriority.unassignedUnread:
        return 3.0;
      case ConversationPriority.normal:
        return 0.0;
    }
  }

  void _handleTap() {
    // Haptic feedback on tap
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = ViernesColors.getTextColor(isDark);
    final priority = _getVisualPriority(context);
    final borderColor = _getBorderColor(priority);
    final borderWidth = _getBorderWidth(priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
      child: _buildCardWithPriorityBorder(
        isDark: isDark,
        priority: priority,
        borderColor: borderColor,
        borderWidth: borderWidth,
        child: ViernesGlassmorphismCard(
          borderRadius: ViernesSpacing.radiusXxl,
          padding: const EdgeInsets.all(ViernesSpacing.md),
          onTap: _handleTap,
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
                  UnreadCountBadge(
                    count: widget.conversation.unreaded,
                    priority: priority,
                  ),
              ],
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Divider
            Container(
              height: 1,
              color: textColor.withValues(alpha: 0.1),
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Message preview with sender and timestamp
            Consumer<ConversationProvider>(
              builder: (context, provider, child) {
                final firstMessage = provider.getFirstMessage(widget.conversation.id);
                final isLoading = provider.isLoadingFirstMessage(widget.conversation.id);

                if (isLoading) {
                  return _buildShimmerPreview(isDark);
                }

                return _buildMessagePreview(
                  textColor: textColor,
                  message: firstMessage ?? _getMessagePreview(),
                  isDark: isDark,
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  /// Wraps the card with a left border based on priority
  Widget _buildCardWithPriorityBorder({
    required bool isDark,
    required ConversationPriority priority,
    required Color? borderColor,
    required double borderWidth,
    required Widget child,
  }) {
    if (priority == ConversationPriority.normal || borderColor == null) {
      return child;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusXxl),
        boxShadow: priority == ConversationPriority.myUnread
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: isDark ? 0.4 : 0.25),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(-2, 0),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusXxl),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final fullname = widget.conversation.user?.fullname ?? '';
    final initial = fullname.isNotEmpty ? fullname[0].toUpperCase() : '?';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priority = _getVisualPriority(context);

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main avatar
          Container(
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
          ),

          // Unread indicator dot
          if (priority != ConversationPriority.normal)
            Positioned(
              right: 2,
              top: 0,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = priority == ConversationPriority.myUnread
                      ? _pulseAnimation.value
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: priority == ConversationPriority.myUnread
                        ? ViernesColors.accent
                        : ViernesColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1a1a1a) : Colors.white,
                      width: 2,
                    ),
                    boxShadow: priority == ConversationPriority.myUnread
                        ? [
                            BoxShadow(
                              color: ViernesColors.accent.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds shimmer loading effect for message preview
  Widget _buildShimmerPreview(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2a2a2a) : const Color(0xFFe0e0e0),
      highlightColor: isDark ? const Color(0xFF3a3a3a) : const Color(0xFFf5f5f5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender + timestamp placeholder
          Row(
            children: [
              Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Message text placeholder
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: ViernesSpacing.xs),
              Expanded(
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the message preview with sender and timestamp
  Widget _buildMessagePreview({
    required Color textColor,
    required String message,
    required bool isDark,
  }) {
    // Determine sender based on agent assignment
    // If message starts with an agent indicator or we can infer it
    String senderLabel;
    IconData senderIcon;

    // Simple heuristic: if the agent is assigned, recent messages might be from agent
    // Otherwise assume customer. For better accuracy, we'd need message metadata.
    if (widget.conversation.agent != null) {
      // Has agent assigned - could be agent or customer reply
      senderLabel = 'Customer';
      senderIcon = Icons.person_outline;
    } else if (message.toLowerCase().contains('[viernes]') ||
               message.toLowerCase().contains('asistente')) {
      senderLabel = 'Viernes';
      senderIcon = Icons.smart_toy_outlined;
    } else {
      senderLabel = 'Customer';
      senderIcon = Icons.person_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender + timestamp row
        Row(
          children: [
            Icon(
              senderIcon,
              size: 12,
              color: textColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              senderLabel,
              style: ViernesTextStyles.bodySmall.copyWith(
                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '·',
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: textColor.withValues(alpha: 0.4),
                ),
              ),
            ),
            Text(
              _formatTimeAgo(widget.conversation.updatedAt),
              style: ViernesTextStyles.bodySmall.copyWith(
                color: textColor.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Message text with icon
        Row(
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
                '"$message"',
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: textColor.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
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
