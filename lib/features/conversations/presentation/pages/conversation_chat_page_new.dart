import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/conversation_chat_notifier.dart';
import '../providers/conversation_chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/message_input.dart';

class ConversationChatPageNew extends ConsumerStatefulWidget {
  final int conversationId;

  const ConversationChatPageNew({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ConversationChatPageNew> createState() => _ConversationChatPageNewState();
}

class _ConversationChatPageNewState extends ConsumerState<ConversationChatPageNew> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatState = ref.watch(conversationChatNotifierProvider(widget.conversationId));
    final chatNotifier = ref.read(conversationChatNotifierProvider(widget.conversationId).notifier);

    // Auto-scroll when new messages arrive
    ref.listen(conversationChatNotifierProvider(widget.conversationId), (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: _buildAppBar(context, chatState, l10n),
      body: Column(
        children: [
          if (chatState.sseError != null) _buildSSEErrorBanner(chatState, chatNotifier, l10n),
          Expanded(
            child: _buildMessagesList(chatState, l10n),
          ),
          MessageInput(
            onSendMessage: chatNotifier.sendMessage,
            isSending: chatState.isSendingMessage,
            hint: l10n.typeMessage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ConversationChatState chatState, AppLocalizations l10n) {
    final theme = Theme.of(context);

    if (chatState.isLoading || chatState.conversation == null) {
      return AppBar(
        title: Text(l10n.loading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      );
    }

    final conversation = chatState.conversation!;
    final user = conversation.user;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.fullname,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: chatState.isConnectedToSSE ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                chatState.isConnectedToSSE ? l10n.online : l10n.connecting,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Conversation Info'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  Text('Assign Agent'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined),
                  SizedBox(width: 8),
                  Text('Change Status'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(value, conversation),
        ),
      ],
    );
  }

  Widget _buildSSEErrorBanner(ConversationChatState chatState, dynamic chatNotifier, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange[100],
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange[800],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${l10n.connectionIssue}: ${chatState.sseError}',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () => chatNotifier.clearSSEError(),
            child: Text(
              l10n.dismiss,
              style: TextStyle(color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ConversationChatState chatState, AppLocalizations l10n) {
    if (chatState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatState.error != null) {
      return _buildErrorWidget(chatState.error!, l10n);
    }

    if (!chatState.hasMessages) {
      return _buildEmptyMessagesWidget(l10n);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: chatState.messages.length + (chatState.hasTypingIndicator ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length) {
          // Typing indicator
          return TypingIndicatorWidget(
            typingIndicator: chatState.typingIndicator!,
          );
        }

        final message = chatState.messages[index];
        return MessageBubble(message: message);
      },
    );
  }

  Widget _buildErrorWidget(String error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingConversation,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final chatNotifier = ref.read(
                  conversationChatNotifierProvider(widget.conversationId).notifier,
                );
                chatNotifier.clearError();
                chatNotifier.loadConversation(widget.conversationId);
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMessagesWidget(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noMessagesYet,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startConversationMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, dynamic conversation) {
    switch (action) {
      case 'info':
        _showConversationInfo(conversation);
        break;
      case 'assign':
        _showAssignDialog(conversation);
        break;
      case 'status':
        _showStatusDialog(conversation);
        break;
    }
  }

  void _showConversationInfo(dynamic conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conversation Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${conversation.user.fullname}'),
            Text('Email: ${conversation.user.email}'),
            Text('Status: ${conversation.status.description}'),
            Text('Priority: ${conversation.priority}'),
            Text('Category: ${conversation.category}'),
            Text('Channel: ${conversation.user.instance}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(dynamic conversation) {
    // TODO: Implement assign agent dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assign agent feature coming soon'),
      ),
    );
  }

  void _showStatusDialog(dynamic conversation) {
    // TODO: Implement change status dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Change status feature coming soon'),
      ),
    );
  }
}