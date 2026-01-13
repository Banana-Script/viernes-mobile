import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_dimensions.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/timezone/timezone_manager.dart';
import '../../../../core/utils/customer_insight_helper.dart';
import '../../../../core/utils/timezone_utils.dart';
import '../../../../core/constants/insight_features.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../../shared/widgets/customer_detail/section_header.dart';
import '../../../../shared/widgets/customer_detail/info_row.dart';
import '../../../../shared/widgets/customer_detail/metric_card.dart';
import '../../../../shared/widgets/customer_detail/insight_badge.dart';
import '../../../../shared/widgets/customer_detail/summary_panel.dart';
import '../../../../shared/widgets/customer_detail/insights_panel.dart';
import '../../../../shared/widgets/customer_detail/sentiment_analysis_panel.dart';
import '../../../../shared/widgets/customer_detail/purchase_intention_chart.dart';
import '../../../../shared/widgets/customer_detail/main_interest_panel.dart';
import '../../../../shared/widgets/customer_detail/interactions_panel.dart';
import '../../../../shared/widgets/customer_detail/conversation_history_table.dart';
import '../../domain/entities/customer_entity.dart';
import '../providers/customer_provider.dart';
import '../../../conversations/presentation/pages/conversation_detail_page.dart';
import '../../../conversations/presentation/providers/conversation_provider.dart';
import '../../../customers/domain/entities/conversation_entity.dart';
import 'customer_form_page.dart';

/// Customer Detail Page
///
/// Displays comprehensive customer information across 3 tabs:
/// - Overview: Essential customer info, summary, and insights
/// - Analysis: Deep insights including sentiment, purchase intention, and NPS
/// - Activity: Interactions, metrics, and conversation history
///
/// Improvements:
/// - Uses CustomerInsightHelper for insight extraction
/// - Uses InsightFeatures constants for feature names
/// - Uses ViernesDimensions for sizing
/// - Uses DateFormatters for date formatting
/// - Proper disposal handling to prevent setState after dispose
class CustomerDetailPage extends ConsumerStatefulWidget {
  final int userId;
  final CustomerEntity? customer; // Optional - for hero animation

  const CustomerDetailPage({
    super.key,
    required this.userId,
    this.customer,
  });

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isStartingChat = false; // Loading state for chat action
  bool _canDirectChat = false; // Whether conversation is within 24h window
  String? _errorMessage;
  late TabController _tabController;
  bool _isDisposed = false; // Disposal flag to prevent setState after dispose

  // Conversation history state
  List<ConversationEntity> _userConversations = [];
  bool _isLoadingConversations = false;
  bool _hasMoreConversationPages = false;
  int _conversationCurrentPage = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCustomerDetail();
  }

  @override
  void dispose() {
    _isDisposed = true; // Set flag before disposing
    _tabController.dispose();
    super.dispose();
  }


  Future<void> _loadCustomerDetail() async {
    if (_isDisposed) return; // Check before setState

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _canDirectChat = false;
    });

    try {
      final customerProvider = provider_pkg.Provider.of<CustomerProvider>(context, listen: false);
      await customerProvider.getCustomerById(widget.userId);

      // Check 24h window if customer has a conversation
      final customer = customerProvider.selectedCustomer;
      if (customer?.lastConversation != null && !customer!.lastConversation!.locked) {
        await _checkConversation24hWindow(customer.lastConversation!.id);
      }

      // Load user's conversation history
      await _loadUserConversations(resetPage: true);
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      // Avoid return in finally - use if statement instead
      if (!_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Check if conversation is within 24h window
  Future<void> _checkConversation24hWindow(int conversationId) async {
    if (_isDisposed) return;

    try {
      final conversationProvider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
      final conversation = await conversationProvider.getConversationDetail(conversationId);

      if (conversation != null && !_isDisposed) {
        setState(() {
          _canDirectChat = _isWithin24HourWindow(conversation);
        });
      }
    } catch (e) {
      // Silently fail - just don't show chat option
      debugPrint('[CustomerDetail] Error checking 24h window: $e');
    }
  }

  /// Load user's conversation history
  Future<void> _loadUserConversations({bool resetPage = false, int? targetPage}) async {
    if (_isDisposed) return;

    final pageToLoad = targetPage ?? (resetPage ? 1 : _conversationCurrentPage);

    if (resetPage) {
      _userConversations = [];
    }

    setState(() {
      _isLoadingConversations = true;
    });

    try {
      final conversationProvider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);
      final result = await conversationProvider.loadUserConversations(
        userId: widget.userId,
        page: pageToLoad,
        pageSize: 10,
      );

      if (!_isDisposed) {
        setState(() {
          if (resetPage) {
            _userConversations = result.conversations;
          } else {
            // Create new list to ensure proper change detection
            _userConversations = [..._userConversations, ...result.conversations];
          }
          _conversationCurrentPage = result.currentPage;
          _hasMoreConversationPages = result.currentPage < result.totalPages;
          _isLoadingConversations = false;
        });
      }
    } catch (e) {
      debugPrint('[CustomerDetail] Error loading user conversations: $e');
      if (!_isDisposed) {
        setState(() {
          _isLoadingConversations = false;
        });
      }
    }
  }

  /// Load more conversations (pagination)
  void _loadMoreConversations() {
    if (_isLoadingConversations || !_hasMoreConversationPages) return;
    // Pass target page to avoid race condition - page only updates on success
    _loadUserConversations(targetPage: _conversationCurrentPage + 1);
  }

  Future<void> _onRefresh() async {
    await _loadCustomerDetail();
  }

  void _navigateToEditForm(CustomerEntity customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormPage(
          mode: CustomerFormMode.edit,
          customer: customer,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _onRefresh();
      }
    });
  }

  /// Check if conversation is within 24h window for direct chat
  /// Similar to frontend's isTemplateSelectionNeeded()
  bool _isWithin24HourWindow(ConversationEntity conversation) {
    if (conversation.locked) return false;

    final now = DateTime.now().toUtc();
    final lastUpdate = conversation.updatedAt.toUtc();
    final diffInHours = now.difference(lastUpdate).inHours;
    return diffInHours < 24;
  }

  Future<void> _navigateToChat(CustomerEntity customer) async {
    if (customer.lastConversation == null) return;
    if (_isStartingChat) return; // Prevent multiple taps

    final conversationId = customer.lastConversation!.id;
    final l10n = AppLocalizations.of(context);

    setState(() => _isStartingChat = true);

    try {
      final conversationProvider = provider_pkg.Provider.of<ConversationProvider>(context, listen: false);

      // Reopen conversation and assign to current agent (like frontend does)
      final success = await conversationProvider.assignConversationToMe(conversationId, reopen: true);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conversationProvider.errorMessage ?? l10n?.anErrorOccurred ?? 'Error opening conversation'),
            backgroundColor: ViernesColors.danger,
          ),
        );
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationDetailPage(
              conversationId: conversationId,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingChat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: provider_pkg.Consumer<CustomerProvider>(
            builder: (context, provider, _) {
              final customer = provider.selectedCustomer;

              if (_isLoading && customer == null) {
                return _buildLoadingState(isDark, l10n);
              }

              if (_errorMessage != null && customer == null) {
                return _buildErrorState(isDark, l10n);
              }

              if (customer == null) {
                return _buildNotFoundState(isDark, l10n);
              }

              return _buildContent(customer, isDark, l10n);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(CustomerEntity customer, bool isDark, AppLocalizations? l10n) {
    return Column(
      children: [
        // App Bar with customer name
        _buildAppBar(customer, isDark),
        // Hero Section (always visible)
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ViernesSpacing.md,
            ViernesSpacing.sm,
            ViernesSpacing.md,
            ViernesSpacing.sm,
          ),
          child: _buildHeroSection(customer, isDark, l10n),
        ),
        // Tab Bar
        _buildTabBar(isDark, l10n),
        // Tab Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
            backgroundColor: isDark ? ViernesColors.panelDark : ViernesColors.panelLight,
            child: TabBarView(
              controller: _tabController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildOverviewTab(customer, isDark, l10n),
                _buildAnalysisTab(customer, isDark, l10n),
                _buildActivityTab(customer, isDark, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(CustomerEntity customer, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              customer.name,
              style: ViernesTextStyles.h5.copyWith(
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Show loading indicator when starting chat
          if (_isStartingChat)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? ViernesColors.accent : ViernesColors.primary,
                ),
              ),
            )
          else
            // 3-dot menu with actions - styled with Viernes glassmorphism design
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              ),
              // Glassmorphism-styled popup surface
              color: isDark
                  ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              surfaceTintColor: Colors.transparent,
              shadowColor: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.15),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                      : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              offset: const Offset(0, ViernesSpacing.xs),
              position: PopupMenuPosition.under,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _navigateToEditForm(customer);
                    break;
                  case 'chat':
                    _navigateToChat(customer);
                    break;
                }
              },
              itemBuilder: (context) => [
                // Edit option - always visible
                PopupMenuItem<String>(
                  value: 'edit',
                  height: ViernesDimensions.listItemHeightCompact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ViernesSpacing.md,
                    vertical: ViernesSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: isDark ? ViernesColors.accent : ViernesColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: ViernesSpacing.sm),
                      Text(
                        l10n?.edit ?? 'Edit',
                        style: ViernesTextStyles.bodyText.copyWith(
                          color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat option - only visible if within 24h window
                if (_canDirectChat)
                  PopupMenuItem<String>(
                    value: 'chat',
                    height: ViernesDimensions.listItemHeightCompact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ViernesSpacing.md,
                      vertical: ViernesSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [ViernesColors.accent, ViernesColors.accentLight]
                                  : [ViernesColors.primary, ViernesColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                            boxShadow: [
                              BoxShadow(
                                color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.chat_bubble_rounded,
                            color: isDark ? Colors.black : Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: ViernesSpacing.sm),
                        Text(
                          l10n?.startChat ?? 'Start Chat',
                          style: ViernesTextStyles.bodyText.copyWith(
                            color: isDark ? ViernesColors.accent : ViernesColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(CustomerEntity customer, bool isDark, AppLocalizations? l10n) {
    final timezone = ref.watch(currentTimezoneProvider);
    final locale = Localizations.localeOf(context);
    final localeCode = locale.languageCode;

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius24,
      padding: const EdgeInsets.all(ViernesSpacing.lg),
      child: Column(
        children: [
          // Avatar with hero animation
          Hero(
            tag: 'customer_avatar_${customer.id}',
            child: Container(
              width: ViernesDimensions.avatarSize,
              height: ViernesDimensions.avatarSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ViernesColors.secondary.withValues(alpha: 0.9),
                    ViernesColors.accent.withValues(alpha: 0.9),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: ViernesTextStyles.h2.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: ViernesSpacing.md),
          // Name
          Text(
            customer.name,
            style: ViernesTextStyles.h4.copyWith(
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ViernesSpacing.xs),
          // Email
          Text(
            customer.email,
            style: ViernesTextStyles.bodyText.copyWith(
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          // Member since
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ViernesSpacing.sm,
              vertical: ViernesSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
            ),
            child: Text(
              '${l10n?.memberSince ?? 'Member since'} ${TimezoneUtils.formatMonthYear(customer.createdAt, timezone, localeCode)}',
              style: ViernesTextStyles.labelSmall.copyWith(
                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, AppLocalizations? l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.xs,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isDark ? ViernesColors.panelDark : ViernesColors.panelLight)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
        border: Border.all(
          color: (isDark ? ViernesColors.primaryLight : ViernesColors.primaryLight)
              .withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        // Custom indicator with gradient and shadow
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    ViernesColors.accent,
                    ViernesColors.accent.withValues(alpha: 0.8),
                  ]
                : [
                    ViernesColors.primary,
                    ViernesColors.primary.withValues(alpha: 0.9),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        // Smooth animation
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        // Selected tab styling
        labelColor: Colors.white,
        labelStyle: ViernesTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        // Unselected tab styling
        unselectedLabelColor: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
            .withValues(alpha: 0.5),
        unselectedLabelStyle: ViernesTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        // Tabs
        tabs: [
          _buildTab(
            icon: Icons.person_rounded,
            label: l10n?.overviewTab ?? 'Overview',
            isDark: isDark,
          ),
          _buildTab(
            icon: Icons.analytics_rounded,
            label: l10n?.analysisTab ?? 'Analysis',
            isDark: isDark,
          ),
          _buildTab(
            icon: Icons.history_rounded,
            label: l10n?.activityTab ?? 'Activity',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Build individual tab with consistent sizing using ViernesDimensions
  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Tab(
      height: ViernesDimensions.tabHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: ViernesDimensions.tabIconSize),
          const SizedBox(height: ViernesDimensions.tabIconSpacing),
          Text(label),
        ],
      ),
    );
  }

  // ==================== TAB 1: OVERVIEW ====================
  Widget _buildOverviewTab(CustomerEntity customer, bool isDark, AppLocalizations? l10n) {
    return ListView(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Personal Information Section
        _buildContactSection(customer, isDark, l10n),
        const SizedBox(height: ViernesSpacing.md),
        // Segment Section
        _buildSegmentSection(customer, isDark, l10n),
        const SizedBox(height: ViernesSpacing.md),
        // Summary Panel - no longer passes languageCode, accesses context internally
        _buildSummaryPanel(customer, isDark),
        const SizedBox(height: ViernesSpacing.md),
        // Insights Panel - no longer passes languageCode, accesses context internally
        _buildInsightsPanel(customer, isDark),
        const SizedBox(height: ViernesSpacing.xl),
      ],
    );
  }

  Widget _buildContactSection(CustomerEntity customer, bool isDark, AppLocalizations? l10n) {
    final timezone = ref.watch(currentTimezoneProvider);
    final locale = Localizations.localeOf(context);
    final localeCode = locale.languageCode;

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.contact_phone_rounded,
            title: l10n?.contactInformation ?? 'Contact Information',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          InfoRow(
            icon: Icons.email_rounded,
            label: l10n?.email ?? 'Email',
            value: customer.email,
            isDark: isDark,
          ),
          InfoRow(
            icon: Icons.phone_rounded,
            label: l10n?.phone ?? 'Phone',
            value: customer.phoneNumber,
            isDark: isDark,
          ),
          InfoRow(
            icon: Icons.calendar_today_rounded,
            label: l10n?.created ?? 'Created',
            value: TimezoneUtils.formatFullDate(customer.createdAt, timezone, localeCode),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentSection(CustomerEntity customer, bool isDark, AppLocalizations? l10n) {
    if (customer.segment == null && customer.segmentSummary == null) {
      return const SizedBox.shrink();
    }

    // Get current locale for multilingual support
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.category_rounded,
            title: l10n?.customerSegment ?? 'Customer Segment',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.sm),
          if (customer.segment != null)
            InsightBadge(
              text: customer.segment!,
              isDark: isDark,
              color: isDark ? ViernesColors.secondary : ViernesColors.secondaryDark,
            ),
          if (customer.segmentSummary != null) ...[
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              CustomerInsightHelper.getInsightValue(
                customer,
                'segment_summary',
                languageCode: languageCode,
              ),
              style: ViernesTextStyles.bodyText.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(CustomerEntity customer, bool isDark) {
    return SummaryPanel(
      customer: customer,
      isDark: isDark,
    );
  }

  Widget _buildInsightsPanel(CustomerEntity customer, bool isDark) {
    return InsightsPanel(
      customer: customer,
      isDark: isDark,
    );
  }

  // ==================== TAB 2: ANALYSIS ====================
  Widget _buildAnalysisTab(CustomerEntity customer, bool isDark, AppLocalizations? l10n) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    return ListView(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Sentiment Analysis Panel
        _buildSentimentAnalysisPanel(customer, isDark),
        const SizedBox(height: ViernesSpacing.md),
        // Purchase Intention Chart
        _buildPurchaseIntentionChart(customer, isDark, languageCode, l10n),
        const SizedBox(height: ViernesSpacing.md),
        // Main Interest Panel (includes NPS)
        _buildMainInterestPanel(customer, isDark, languageCode, l10n),
        const SizedBox(height: ViernesSpacing.xl),
      ],
    );
  }

  Widget _buildSentimentAnalysisPanel(CustomerEntity customer, bool isDark) {
    return SentimentAnalysisPanel(
      customer: customer,
      isDark: isDark,
    );
  }

  Widget _buildPurchaseIntentionChart(CustomerEntity customer, bool isDark, String languageCode, AppLocalizations? l10n) {
    // Use CustomerInsightHelper with constant
    final purchaseIntention = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.purchaseIntention,
      languageCode: languageCode,
    );

    if (purchaseIntention.isEmpty || purchaseIntention == 'N/A') {
      return const SizedBox.shrink();
    }

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.shopping_bag_rounded,
            title: l10n?.purchaseIntention ?? 'Purchase Intention',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.md),
          PurchaseIntentionChart(
            currentIntention: purchaseIntention,
            isDark: isDark,
            languageCode: languageCode,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInterestPanel(CustomerEntity customer, bool isDark, String languageCode, AppLocalizations? l10n) {
    // Use CustomerInsightHelper with constants
    final mainInterest = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.mainInterest,
      languageCode: languageCode,
    );
    final otherTopics = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.otherTopics,
      languageCode: languageCode,
    );
    // Try both NPS field names
    final nps = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.nps,
      languageCode: languageCode,
    ).isNotEmpty
        ? CustomerInsightHelper.getInsightValue(
            customer,
            InsightFeatures.nps,
            languageCode: languageCode,
          )
        : CustomerInsightHelper.getInsightValue(
            customer,
            InsightFeatures.netPromoterScore,
            languageCode: languageCode,
          );

    if (mainInterest.isEmpty && otherTopics.isEmpty && nps.isEmpty) {
      return const SizedBox.shrink();
    }

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.interests_rounded,
            title: l10n?.mainInterestNps ?? 'Main Interest & NPS',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.md),
          MainInterestPanel(
            mainInterest: mainInterest.isNotEmpty ? mainInterest : null,
            otherTopics: otherTopics.isNotEmpty ? otherTopics : null,
            npsValue: nps.isNotEmpty ? nps : null,
            isDark: isDark,
            languageCode: languageCode,
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: ACTIVITY ====================
  Widget _buildActivityTab(CustomerEntity customer, bool isDark, AppLocalizations? l10n) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    return ListView(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Metrics Grid
        _buildMetricsGrid(customer, isDark, languageCode, l10n),
        const SizedBox(height: ViernesSpacing.md),
        // Interactions Panel
        _buildInteractionsPanel(customer, isDark, languageCode),
        const SizedBox(height: ViernesSpacing.md),
        // Conversation History Table
        _buildConversationHistoryTable(customer, isDark),
        const SizedBox(height: ViernesSpacing.xl),
      ],
    );
  }

  Widget _buildMetricsGrid(CustomerEntity customer, bool isDark, String languageCode, AppLocalizations? l10n) {
    final timezone = ref.watch(currentTimezoneProvider);

    // Use CustomerInsightHelper with constant
    final purchaseIntention = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.purchaseIntention,
      languageCode: languageCode,
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: ViernesSpacing.sm,
      crossAxisSpacing: ViernesSpacing.sm,
      childAspectRatio: ViernesDimensions.metricCardAspectRatio,
      children: [
        MetricCard(
          icon: Icons.chat_bubble_rounded,
          label: l10n?.conversationsLabel ?? 'Conversations',
          value: customer.lastConversation != null ? '1+' : '0',
          isDark: isDark,
          iconColor: ViernesColors.info,
        ),
        MetricCard(
          icon: Icons.access_time_rounded,
          label: l10n?.lastContact ?? 'Last Interaction',
          value: customer.lastInteraction != null
              ? TimezoneUtils.formatRelativeTime(customer.lastInteraction!, timezone, languageCode, l10n)
              : l10n?.never ?? 'Never',
          isDark: isDark,
          iconColor: ViernesColors.warning,
        ),
        MetricCard(
          icon: Icons.insights_rounded,
          label: l10n?.insightsLabel ?? 'Insights',
          value: customer.insightsInfo.length.toString(),
          isDark: isDark,
          iconColor: ViernesColors.accent,
        ),
        MetricCard(
          icon: Icons.shopping_bag_rounded,
          label: l10n?.purchaseIntent ?? 'Purchase Intent',
          value: purchaseIntention.isNotEmpty ? purchaseIntention : l10n?.unknown ?? 'Unknown',
          isDark: isDark,
          iconColor: ViernesColors.success,
        ),
      ],
    );
  }

  Widget _buildInteractionsPanel(CustomerEntity customer, bool isDark, String languageCode) {
    // Use CustomerInsightHelper with constants
    final interactionsPerMonth = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.interactionsPerMonth,
      languageCode: languageCode,
    );
    final lastInteractionReasons = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.lastInteractionsReason,
      languageCode: languageCode,
    );
    final actionsToCall = CustomerInsightHelper.getInsightValue(
      customer,
      InsightFeatures.actionsToCall,
      languageCode: languageCode,
    );

    return InteractionsPanel(
      interactionsPerMonth: interactionsPerMonth.isNotEmpty ? interactionsPerMonth : null,
      lastInteractionReasons: lastInteractionReasons.isNotEmpty ? lastInteractionReasons : null,
      actionsToCall: actionsToCall.isNotEmpty ? actionsToCall : null,
      isDark: isDark,
      languageCode: languageCode,
    );
  }

  /// Build conversation history table
  ///
  /// Displays customer's conversation history loaded from the API.
  Widget _buildConversationHistoryTable(CustomerEntity customer, bool isDark) {
    final timezone = ref.watch(currentTimezoneProvider);

    return ConversationHistoryTable(
      conversations: _userConversations,
      isDark: isDark,
      timezone: timezone,
      isLoading: _isLoadingConversations,
      hasMorePages: _hasMoreConversationPages,
      onRefresh: () async {
        await _loadUserConversations(resetPage: true);
      },
      onLoadMore: _loadMoreConversations,
      onViewConversation: (conversation) {
        // Navigate to conversation detail page
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
  }

  // ==================== STATE WIDGETS ====================
  Widget _buildLoadingState(bool isDark, AppLocalizations? l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
          ),
          const SizedBox(height: ViernesSpacing.md),
          Text(
            l10n?.loadingCustomerDetails ?? 'Loading customer details...',
            style: ViernesTextStyles.bodyText.copyWith(
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, AppLocalizations? l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: ViernesDimensions.iconSizeXLarge + 16,
              color: ViernesColors.danger.withValues(alpha: 0.5),
            ),
            const SizedBox(height: ViernesSpacing.md),
            Text(
              l10n?.errorLoadingCustomer ?? 'Error Loading Customer',
              style: ViernesTextStyles.h5.copyWith(
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              ),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              _errorMessage ?? (l10n?.anErrorOccurred ?? 'An error occurred'),
              style: ViernesTextStyles.bodyText.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.lg),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n?.retry ?? 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? ViernesColors.accent : ViernesColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(bool isDark, AppLocalizations? l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: ViernesDimensions.iconSizeXLarge + 16,
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: ViernesSpacing.md),
            Text(
              l10n?.customerNotFound ?? 'Customer Not Found',
              style: ViernesTextStyles.h5.copyWith(
                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              ),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              l10n?.customerNotFoundMessage ?? 'The customer you are looking for does not exist.',
              style: ViernesTextStyles.bodyText.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n?.goBack ?? 'Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? ViernesColors.accent : ViernesColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
