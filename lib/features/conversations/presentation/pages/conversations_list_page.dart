import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/list_components/index.dart';
import '../providers/conversation_provider.dart';
import '../widgets/conversation_card.dart';
import '../widgets/conversation_filter_modal.dart';
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
    _scrollController.removeListener(_onScroll);
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
    return const ViernesPageHeader(title: 'Conversations');
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: ViernesSearchBar(
              controller: _searchController,
              hintText: 'Search conversations...',
              onSearchChanged: (value) {
                final provider = Provider.of<ConversationProvider>(context, listen: false);
                provider.updateSearchTerm(value);
                provider.applySearch();
              },
              onClear: _clearSearch,
            ),
          ),
          const SizedBox(width: ViernesSpacing.sm),
          _buildFilterButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, bool isDark) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final hasActiveFilters = provider.filters.activeFilterCount > 0;

        return Stack(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                      : const Color(0xFFe5e7eb).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
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
                  borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                  child: Center(
                    child: Icon(
                      Icons.filter_list,
                      color: isDark ? ViernesColors.accent : ViernesColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            if (hasActiveFilters)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ViernesColors.secondary.withValues(alpha: 0.9),
                        ViernesColors.accent.withValues(alpha: 0.9),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? ViernesColors.backgroundDark
                          : ViernesColors.backgroundLight,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      '${provider.filters.activeFilterCount}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
        final activeFilters = provider.filters.getActiveFilterLabels(
          availableStatuses: provider.availableStatuses,
          availableAgents: provider.availableAgents,
        );

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
          return const ViernesListSkeleton(
            preset: ViernesSkeletonPreset.conversation,
          );
        }

        // Error state
        if (provider.status == ConversationStatus.error &&
            provider.conversations.isEmpty) {
          return ViernesErrorState(
            message: provider.errorMessage ?? 'Error loading conversations',
            onRetry: () => provider.retry(),
          );
        }

        // Empty state
        if (provider.conversations.isEmpty) {
          return ViernesEmptyState(
            message: 'No conversations found',
            icon: Icons.chat_bubble_outline,
            hasFilters: provider.searchTerm.isNotEmpty || provider.filters.hasActiveFilters,
            description: provider.searchTerm.isNotEmpty || provider.filters.hasActiveFilters
                ? 'Try adjusting your filters'
                : 'Conversations will appear here',
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
