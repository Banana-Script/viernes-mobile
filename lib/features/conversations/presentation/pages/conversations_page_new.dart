import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/conversations_notifier.dart';
import '../providers/conversations_state.dart';
import '../widgets/conversation_card.dart';
import '../widgets/conversations_search_bar.dart';
import '../widgets/conversations_view_tabs.dart';

class ConversationsPageNew extends ConsumerStatefulWidget {
  const ConversationsPageNew({super.key});

  @override
  ConsumerState<ConversationsPageNew> createState() => _ConversationsPageNewState();
}

class _ConversationsPageNewState extends ConsumerState<ConversationsPageNew> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load conversations when the page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsNotifierProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more conversations when near the bottom
      ref.read(conversationsNotifierProvider.notifier).loadConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final conversationsState = ref.watch(conversationsNotifierProvider);
    final conversationsNotifier = ref.read(conversationsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.conversations),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              conversationsNotifier.loadConversations(refresh: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          conversationsNotifier.loadConversations(refresh: true);
        },
        child: Column(
          children: [
            ConversationsViewTabs(
              selectedView: conversationsState.viewMode,
              onViewChanged: conversationsNotifier.changeViewMode,
            ),
            ConversationsSearchBar(
              hint: l10n.searchConversations,
              onSearchChanged: conversationsNotifier.searchConversations,
              onFilterTap: _showFiltersDialog,
              hasActiveFilters: conversationsState.filters.isNotEmpty,
            ),
            Expanded(
              child: _buildConversationsList(conversationsState, conversationsNotifier, l10n),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConversationsList(
    ConversationsState state,
    ConversationsNotifier notifier,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.isFirstPage) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return _buildErrorWidget(state.error!, notifier, l10n);
    }

    if (state.isEmpty) {
      return _buildEmptyWidget();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80), // Space for FAB
      itemCount: state.conversations.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.conversations.length) {
          // Loading indicator at the bottom
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final conversation = state.conversations[index];
        return ConversationCard(
          conversation: conversation,
          onTap: () => _openConversation(conversation.id),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error, ConversationsNotifier notifier, AppLocalizations l10n) {
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
              l10n.errorLoadingConversations,
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
                notifier.clearError();
                notifier.loadConversations(refresh: true);
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final l10n = AppLocalizations.of(context)!;

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
              l10n.noConversationsYet,
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startNewConversation,
              icon: const Icon(Icons.add),
              label: Text(l10n.startNewConversation),
            ),
          ],
        ),
      ),
    );
  }

  void _openConversation(int conversationId) {
    context.push('/conversations/$conversationId');
  }

  void _startNewConversation() {
    // TODO: Implement new conversation functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Start new conversation feature coming soon'),
      ),
    );
  }

  void _showFiltersDialog() {
    // TODO: Implement filters dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: const Text('Filter options coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}