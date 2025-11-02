import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_search_bar.dart';
import '../widgets/customer_filter_drawer.dart';
import '../widgets/customer_empty_state.dart';
import '../widgets/customer_loading_skeleton.dart';
import '../widgets/customer_error_state.dart';
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
    super.dispose();
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
          customerId: customer.id,
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

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(isDark),

              const SizedBox(height: ViernesSpacing.md),

              // Search bar
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ViernesSpacing.md,
                ),
                child: CustomerSearchBar(),
              ),

              const SizedBox(height: ViernesSpacing.md),

              // Toggle and filter row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ViernesSpacing.md,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: CustomerViewToggle(),
                    ),
                    const SizedBox(width: ViernesSpacing.sm),
                    _buildFilterButton(isDark),
                  ],
                ),
              ),

              const SizedBox(height: ViernesSpacing.md),

              // Customer list or states
              Expanded(
                child: _buildContent(isDark),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(
        ViernesSpacing.md,
        ViernesSpacing.space5,
        ViernesSpacing.md,
        ViernesSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Customers',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(bool isDark) {
    return provider_pkg.Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final hasActiveFilters = provider.filters.hasActiveFilters;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                      : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openFilterDrawer(context),
                  borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                  child: Padding(
                    padding: const EdgeInsets.all(ViernesSpacing.space3),
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

  void _openFilterDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: const CustomerFilterDrawer(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isDark) {
    return provider_pkg.Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        // Error state
        if (provider.status == CustomerStatus.error) {
          return CustomerErrorState(
            message: provider.errorMessage ?? 'An error occurred',
            onRetry: () => provider.retry(),
          );
        }

        // Initial loading state
        if (provider.status == CustomerStatus.loading && provider.customers.isEmpty) {
          return const CustomerLoadingSkeleton();
        }

        // Empty state
        if (provider.customers.isEmpty && provider.status == CustomerStatus.loaded) {
          return CustomerEmptyState(
            hasFilters: provider.filters.hasActiveFilters || provider.searchTerm.isNotEmpty,
            description: provider.filters.hasActiveFilters || provider.searchTerm.isNotEmpty
                ? 'Try adjusting your filters or search query'
                : 'No customers have been added yet',
            actionLabel: provider.filters.hasActiveFilters ? 'Clear Filters' : 'Add Customer',
            onActionPressed: provider.filters.hasActiveFilters
                ? () => provider.clearFilters()
                : _onAddCustomer,
          );
        }

        // Customer list
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: isDark ? ViernesColors.accent : ViernesColors.primary,
          backgroundColor: isDark
              ? ViernesColors.panelDark
              : ViernesColors.panelLight,
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
