import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../providers/conversation_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/status_badge.dart';
import '../widgets/priority_badge.dart';
import '../widgets/message_composer/message_composer.dart';

/// Conversation Detail Page
///
/// Chat interface for viewing and sending messages in a conversation.
class ConversationDetailPage extends StatefulWidget {
  final int conversationId;

  const ConversationDetailPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load conversation and messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConversationProvider>(context, listen: false);
      provider.selectConversation(widget.conversationId);
    });

    // Setup scroll listener for loading older messages
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more messages when scrolling to top (older messages)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<ConversationProvider>(context, listen: false);
      if (!provider.isLoadingMoreMessages && provider.hasMoreMessages) {
        provider.loadMoreMessages(widget.conversationId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          _buildStatusBar(context, isDark),
          Expanded(
            child: _buildMessagesList(context, isDark),
          ),
          _buildMessageInput(context, isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: ViernesColors.getTextColor(isDark),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Consumer<ConversationProvider>(
        builder: (context, provider, _) {
          final conversation = provider.selectedConversation;
          if (conversation == null) {
            return const Text('Loading...');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.user?.fullname ?? 'Unknown Customer',
                style: ViernesTextStyles.h6.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                ),
              ),
              Text(
                conversation.user?.email ?? '',
                style: ViernesTextStyles.caption.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: ViernesColors.getTextColor(isDark),
          ),
          onPressed: () {
            // TODO: Show actions bottom sheet
          },
        ),
      ],
    );
  }

  Widget _buildStatusBar(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final conversation = provider.selectedConversation;
        if (conversation == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.md,
            vertical: ViernesSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: ViernesColors.getControlBackground(isDark),
            border: Border(
              bottom: BorderSide(
                color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (conversation.status != null)
                StatusBadge(status: conversation.status!.description),
              const SizedBox(width: ViernesSpacing.sm),
              if (conversation.priority != null)
                PriorityBadge(priority: conversation.priority),
              const Spacer(),
              if (conversation.agent != null)
                Text(
                  'Assigned: ${conversation.agent!.fullname}',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        // Loading state
        if (provider.messageStatus == MessageStatus.loading &&
            provider.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (provider.messageStatus == MessageStatus.error &&
            provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: ViernesColors.danger.withValues(alpha: 0.5),
                ),
                const SizedBox(height: ViernesSpacing.md),
                Text(
                  'Error loading messages',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  provider.messageErrorMessage ?? 'Unknown error',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ViernesSpacing.lg),
                ElevatedButton(
                  onPressed: () => provider.loadMessages(
                    widget.conversationId,
                    resetPage: true,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (provider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
                ),
                const SizedBox(height: ViernesSpacing.md),
                Text(
                  'No messages yet',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  'Start the conversation',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Messages list (reversed to show newest at bottom)
        return ListView.builder(
          controller: _scrollController,
          reverse: true, // Newest messages at bottom
          padding: const EdgeInsets.symmetric(
            vertical: ViernesSpacing.lg,
            horizontal: ViernesSpacing.md,
          ),
          itemCount: provider.messages.length +
              (provider.isLoadingMoreMessages ? 1 : 0),
          itemBuilder: (context, index) {
            // Loading indicator at top (for older messages)
            if (index >= provider.messages.length) {
              return const Padding(
                padding: EdgeInsets.all(ViernesSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Messages are reversed, so we need to access them in reverse order
            final message = provider.messages[index];
            return MessageBubble(
              message: message,
              isDark: isDark,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        return MessageComposer(
          conversationId: widget.conversationId,
          isSending: provider.isSendingMessage,
          quickReplies: const [], // TODO: Integrate with quick replies API
          isLoadingQuickReplies: false,
          hasMoreQuickReplies: false,
          onSendMessage: (text) async {
            final success = await provider.sendMessage(widget.conversationId, text);
            if (!success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.messageErrorMessage ?? 'Failed to send message'),
                  backgroundColor: ViernesColors.danger,
                ),
              );
            }
            return success;
          },
          onSendMedia: (attachments, caption) async {
            // TODO: Implement media upload and send
            // For now, just send caption as text if provided
            if (caption != null && caption.isNotEmpty) {
              await provider.sendMessage(widget.conversationId, caption);
            }
          },
          onSearchQuickReplies: (query) {
            // TODO: Integrate with quick replies API
          },
          onLoadMoreQuickReplies: () {
            // TODO: Integrate with quick replies API
          },
        );
      },
    );
  }
}
