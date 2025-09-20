import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

class ConversationsPage extends ConsumerStatefulWidget {
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ConsumerState<ConversationsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.conversations),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Conversations list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 12, // Mock data
              itemBuilder: (context, index) {
                final hasUnreadMessages = index % 3 == 0;
                final isOnline = index % 2 == 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text('C${index + 1}'),
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
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text('Customer ${index + 1}')),
                        if (hasUnreadMessages)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(index % 5) + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLastMessage(index),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: hasUnreadMessages ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTimeAgo(index),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read),
                              SizedBox(width: 8),
                              Text('Mark as Read'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(Icons.archive),
                              SizedBox(width: 8),
                              Text('Archive'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) => _onMenuSelected(value, index),
                    ),
                    onTap: () => _openConversation(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        child: const Icon(Icons.chat),
      ),
    );
  }

  String _getLastMessage(int index) {
    final messages = [
      'Thanks for your help with the order!',
      'When will my package arrive?',
      'I need to change my delivery address',
      'The product looks great, thank you!',
      'Can you help me with a refund?',
    ];
    return messages[index % messages.length];
  }

  String _getTimeAgo(int index) {
    final times = ['2m ago', '1h ago', '3h ago', '1d ago', '2d ago'];
    return times[index % times.length];
  }

  void _onSearchChanged(String query) {
    // TODO: Implement search functionality
  }

  void _onMenuSelected(String value, int index) {
    switch (value) {
      case 'mark_read':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversation ${index + 1} marked as read')),
        );
        break;
      case 'archive':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conversation ${index + 1} archived')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(index);
        break;
    }
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text('Are you sure you want to delete the conversation with Customer ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Conversation ${index + 1} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openConversation(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ConversationDetailPage(customerIndex: index),
      ),
    );
  }

  void _startNewConversation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Start new conversation functionality coming soon')),
    );
  }
}

class _ConversationDetailPage extends StatefulWidget {
  final int customerIndex;

  const _ConversationDetailPage({required this.customerIndex});

  @override
  State<_ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<_ConversationDetailPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer ${widget.customerIndex + 1}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _makeCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _makeVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: 10, // Mock messages
              itemBuilder: (context, index) {
                final isMyMessage = index % 2 == 0;
                return _MessageBubble(
                  message: _getMessageText(index),
                  isMyMessage: isMyMessage,
                  timestamp: DateTime.now().subtract(Duration(minutes: (10 - index) * 5)),
                );
              },
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMessageText(int index) {
    final messages = [
      'Hello! How can I help you today?',
      'I have a question about my recent order',
      'Sure, what would you like to know?',
      'When will it be delivered?',
      'Let me check that for you...',
      'Your order will arrive tomorrow by 3 PM',
      'Perfect! Thank you so much',
      'You\'re welcome! Is there anything else I can help with?',
      'No, that\'s all. Have a great day!',
      'You too! Feel free to reach out anytime.',
    ];
    return messages[index % messages.length];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // TODO: Implement send message functionality
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent!')),
    );
  }

  void _makeCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling Customer ${widget.customerIndex + 1}...')),
    );
  }

  void _makeVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting video call with Customer ${widget.customerIndex + 1}...')),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMyMessage;
  final DateTime timestamp;

  const _MessageBubble({
    required this.message,
    required this.isMyMessage,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isMyMessage
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMyMessage ? const Radius.circular(4) : null,
            bottomLeft: !isMyMessage ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMyMessage ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isMyMessage ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}