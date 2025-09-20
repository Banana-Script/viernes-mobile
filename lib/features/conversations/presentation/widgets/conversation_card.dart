import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/conversation.dart';

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnreadMessages = conversation.unreaded > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: _buildAvatar(context),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.user.fullname,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: hasUnreadMessages ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnreadMessages) _buildUnreadBadge(theme),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildStatusRow(theme),
            const SizedBox(height: 4),
            _buildLastInteractionTime(theme),
          ],
        ),
        trailing: _buildChannelIcon(),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = conversation.user.lastInteraction
        .isAfter(DateTime.now().subtract(const Duration(minutes: 15)));

    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primary.withValues(alpha:0.1),
          child: Text(
            conversation.user.fullname.isNotEmpty
                ? conversation.user.fullname[0].toUpperCase()
                : 'U',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUnreadBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        conversation.unreaded.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusRow(ThemeData theme) {
    return Row(
      children: [
        _buildStatusBadge(theme),
        const SizedBox(width: 8),
        if (conversation.locked)
          Icon(
            Icons.lock,
            size: 14,
            color: Colors.orange[700],
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _getAssignedToText(),
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final status = conversation.status.description.toLowerCase();
    Color badgeColor;

    switch (status) {
      case 'open':
      case 'pending':
        badgeColor = Colors.orange;
        break;
      case 'in progress':
      case 'assigned':
        badgeColor = Colors.blue;
        break;
      case 'completed':
      case 'resolved':
        badgeColor = Colors.green;
        break;
      case 'closed':
        badgeColor = Colors.grey;
        break;
      default:
        badgeColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        conversation.status.description,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getAssignedToText() {
    if (conversation.agent != null) {
      return 'Assigned to ${conversation.agent!.fullname}';
    }
    return 'Assigned to Viernes AI';
  }

  Widget _buildLastInteractionTime(ThemeData theme) {
    final timeAgo = _getTimeAgo(conversation.user.lastInteraction);
    return Text(
      'Last interaction: $timeAgo',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha:0.6),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  Widget _buildChannelIcon() {
    String iconPath;
    switch (conversation.user.instance.toLowerCase()) {
      case 'whatsapp':
        iconPath = 'assets/images/integrations/whatsapp.png';
        break;
      case 'facebook':
      case 'facebook_messenger':
        iconPath = 'assets/images/integrations/facebook.png';
        break;
      case 'instagram':
        iconPath = 'assets/images/integrations/instagram.png';
        break;
      case 'telegram':
        iconPath = 'assets/images/integrations/telegram.png';
        break;
      default:
        return Icon(
          Icons.chat,
          size: 20,
          color: Colors.grey[600],
        );
    }

    return Image.asset(
      iconPath,
      width: 20,
      height: 20,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.chat,
        size: 20,
        color: Colors.grey[600],
      ),
    );
  }
}