import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/list_components/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_filter_modal.dart';
import '../widgets/customer_view_toggle.dart';
import 'customer_detail_page.dart';
import 'customer_form_page.dart';

/// Customer List Page
///
/// Main page for displaying and managing customers in the Viernes mobile app.
///
/// Features:
/// - Customer list with glassmorphism cards
/// - Search bar with debounce
/// - Filter drawer with multiple filter options
/// - Toggle between "All Customers" and "My Customers"
/// - Pull-to-refresh
/// - Infinite scroll pagination
/// - Loading, empty, and error states
/// - FAB for adding new customer
/// - Navigation to customer detail and forms
///
/// Design Philosophy:
/// - Follows Viernes glassmorphism aesthetic
/// - Optimized for mobile viewing
/// - Smooth animations and transitions
/// - Consistent with dashboard and profile pages
class CustomerListPage extends ConsumerStatefulWidget {
  const CustomerListPage({super.key});

  @override
  ConsumerState<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends ConsumerState<CustomerListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize customer provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = provider_pkg.Provider.of<AuthProvider>(context, listen: false);
      final customerProvider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);

      // Get current agent ID from auth provider (user.id from /me endpoint)
      final agentId = authProvider.user?.databaseId;

      // Initialize customer provider with agent ID
      if (customerProvider.status == CustomerStatus.initial) {
        customerProvider.initialize(currentAgentId: agentId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    final provider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);
    provider.updateSearchTerm('');
    provider.applySearch();
  }

  void _onScroll() {
    // Infinite scroll - load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final customerProvider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);
      if (!customerProvider.isLoadingMore && customerProvider.hasMorePages) {
        customerProvider.loadMoreCustomers();
      }
    }
  }

  Future<void> _onRefresh() async {
    final customerProvider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);
    await customerProvider.refresh();
  }

  void _onCustomerTap(CustomerEntity customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(
          userId: customer.userId,
          customer: customer, // For hero animation
        ),
      ),
    ).then((result) {
      // Refresh list if customer was updated or deleted
      if (result == true) {
        _onRefresh();
      }
    });
  }

  void _onAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerFormPage(
          mode: CustomerFormMode.add,
        ),
      ),
    ).then((result) {
      // Refresh list if customer was added
      if (result == true) {
        _onRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(isDark),

              const SizedBox(height: ViernesSpacing.md),

              // Search bar and filter button row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ViernesSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ViernesSearchBar(
                        controller: _searchController,
                        hintText: l10n?.searchCustomers ?? 'Search customers...',
                        onSearchChanged: (value) {
                          final provider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);
                          provider.updateSearchTerm(value);
                          provider.applySearch();
                        },
                        onClear: _clearSearch,
                      ),
                    ),
                    const SizedBox(width: ViernesSpacing.sm),
                    _buildFilterButton(isDark),
                  ],
                ),
              ),

              const SizedBox(height: ViernesSpacing.md),

              // View toggle
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ViernesSpacing.md,
                ),
                child: CustomerViewToggle(),
              ),

              const SizedBox(height: ViernesSpacing.md),

              // Customer list or states
              Expanded(
                child: _buildContent(isDark, l10n),
              ),
            ],
          ),
        ),
      ),
      // FAB for adding customer
      floatingActionButton: _buildFAB(isDark),
    );
  }

  Widget _buildHeader(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return ViernesPageHeader(title: l10n?.customers ?? 'Customers');
  }

  Widget _buildFilterButton(bool isDark) {
    return provider_pkg.Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final hasActiveFilters = provider.filters.hasActiveFilters;

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
                  onTap: () => _openFilterModal(context),
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
            // Badge showing active filter count
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
                      provider.filters.activeFiltersCount.toString(),
                      style: ViernesTextStyles.labelSmall.copyWith(
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

  void _openFilterModal(BuildContext context) {
    final provider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerFilterModal(
        initialFilters: provider.filters,
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations? l10n) {
    return provider_pkg.Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        // Error state
        if (provider.status == CustomerStatus.error) {
          return ViernesErrorState(
            message: provider.errorMessage ?? 'An error occurred',
            onRetry: () => provider.retry(),
          );
        }

        // Initial loading state
        if (provider.status == CustomerStatus.loading && provider.customers.isEmpty) {
          return const ViernesListSkeleton(
            preset: ViernesSkeletonPreset.customer,
          );
        }

        // Empty state
        if (provider.customers.isEmpty && provider.status == CustomerStatus.loaded) {
          return ViernesEmptyState(
            message: l10n?.noCustomersFound ?? 'No customers found',
            icon: Icons.people_outline,
            hasFilters: provider.filters.hasActiveFilters || provider.searchTerm.isNotEmpty,
            description: provider.filters.hasActiveFilters || provider.searchTerm.isNotEmpty
                ? l10n?.tryAdjustingFilters ?? 'Try adjusting your filters or search query'
                : l10n?.noCustomersYet ?? 'No customers have been added yet',
            actionLabel: provider.filters.hasActiveFilters
                ? l10n?.clearFilters ?? 'Clear Filters'
                : l10n?.addCustomer ?? 'Add Customer',
            onActionPressed: provider.filters.hasActiveFilters
                ? () => provider.clearFilters()
                : _onAddCustomer,
          );
        }

        // Customer list
        return SmartRefresher(
          controller: _refreshController,
          onRefresh: () async {
            await _onRefresh();
            _refreshController.refreshCompleted();
          },
          header: WaterDropMaterialHeader(
            backgroundColor: isDark ? ViernesColors.accent : ViernesColors.secondary,
            color: Colors.black,
            distance: 60,
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: ViernesSpacing.md,
              vertical: ViernesSpacing.xs,
            ),
            itemCount: provider.customers.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end while loading more
              if (index >= provider.customers.length) {
                return const Padding(
                  padding: EdgeInsets.all(ViernesSpacing.md),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return CustomerCard(
                customer: provider.customers[index],
                isDark: isDark,
                onTap: () => _onCustomerTap(provider.customers[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFAB(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ViernesColors.secondary.withValues(alpha: 0.9),
            ViernesColors.accent.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: (isDark ? ViernesColors.accent : ViernesColors.secondary)
                .withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onAddCustomer,
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              Icons.add,
              color: Colors.black,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
