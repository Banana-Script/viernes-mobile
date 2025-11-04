import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_circular_icon_button.dart';
import '../providers/conversation_provider.dart';
import '../widgets/conversation_card.dart';
import '../widgets/conversation_filter_modal.dart';
import '../widgets/conversation_search_bar.dart';
import '../widgets/conversation_loading_skeleton.dart';
import '../widgets/conversation_view_toggle.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'conversation_detail_page.dart';

/// Conversations List Page
///
/// Main conversations screen with search, filters, and list.
class ConversationsListPage extends StatefulWidget {
  const ConversationsListPage({super.key});

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize conversations on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conversationProvider = Provider.of<ConversationProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Set current user's agent ID for "My Conversations" filter
      conversationProvider.setCurrentUserAgentId(authProvider.user?.databaseId);

      if (conversationProvider.status == ConversationStatus.initial) {
        conversationProvider.initialize();
      }
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when 200px from bottom
      final provider = Provider.of<ConversationProvider>(context, listen: false);
      if (!provider.isLoadingMore && provider.hasMorePages) {
        provider.loadMoreConversations();
      }
    }
  }

  void _applySearch() {
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    provider.applySearch();
  }

  void _clearSearch() {
    _searchController.clear();
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    provider.updateSearchTerm('');
    provider.applySearch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            _buildSearchBar(context, isDark),
            _buildViewToggle(context),
            _buildActiveFilters(context, isDark),
            Expanded(
              child: _buildConversationsList(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(
        ViernesSpacing.md,
        ViernesSpacing.lg,
        ViernesSpacing.md,
        ViernesSpacing.md,
      ),
      child: Stack(
        children: [
          // Center: Title
          Center(
            child: Text(
              'CONVERSATIONS',
              style: ViernesTextStyles.h5.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
          ),

          // Right: Filter button
          Positioned(
            right: 0,
            child: Consumer<ConversationProvider>(
              builder: (context, provider, _) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Stack(
                  children: [
                    ViernesCircularIconButton(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ConversationFilterModal(
                            initialFilters: provider.filters,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.filter_list,
                        color: isDark ? ViernesColors.accent : ViernesColors.primary,
                        size: 20,
                      ),
                    ),
                    if (provider.filters.activeFilterCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: ViernesColors.accent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${provider.filters.activeFilterCount}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return ConversationSearchBar(
      controller: _searchController,
      hintText: 'Search conversations...',
      onChanged: (value) {
        // Debounced search handled by the widget
        final provider = Provider.of<ConversationProvider>(context, listen: false);
        provider.updateSearchTerm(value);
      },
      onSubmitted: _applySearch,
      onClear: _clearSearch,
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.sm,
      ),
      child: ConversationViewToggle(),
    );
  }

  Widget _buildActiveFilters(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final activeFilters = provider.filters.getActiveFilterLabels();

        if (activeFilters.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.md,
            vertical: ViernesSpacing.sm,
          ),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: activeFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: ViernesSpacing.sm),
            itemBuilder: (context, index) {
              final filter = activeFilters[index];
              return _FilterChip(
                label: filter.label,
                color: filter.color,
                onRemove: () => provider.removeFilter(filter),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildConversationsList(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        // Loading state
        if (provider.status == ConversationStatus.loading &&
            provider.conversations.isEmpty) {
          return const ConversationLoadingSkeleton();
        }

        // Error state
        if (provider.status == ConversationStatus.error &&
            provider.conversations.isEmpty) {
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
                  'Error loading conversations',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  provider.errorMessage ?? 'Unknown error',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ViernesSpacing.lg),
                ElevatedButton(
                  onPressed: () => provider.retry(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (provider.conversations.isEmpty) {
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
                  'No conversations found',
                  style: ViernesTextStyles.h6.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                  ),
                ),
                const SizedBox(height: ViernesSpacing.sm),
                Text(
                  provider.searchTerm.isNotEmpty || provider.filters.hasActiveFilters
                      ? 'Try adjusting your filters'
                      : 'Conversations will appear here',
                  style: ViernesTextStyles.bodySmall.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // List with pull-to-refresh
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              ViernesSpacing.md,
              0,
              ViernesSpacing.md,
              ViernesSpacing.md,
            ),
            itemCount: provider.conversations.length +
                (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator at bottom
              if (index >= provider.conversations.length) {
                return const Padding(
                  padding: EdgeInsets.all(ViernesSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final conversation = provider.conversations[index];
              return ConversationCard(
                conversation: conversation,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationDetailPage(
                        conversationId: conversation.id,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ViernesTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
