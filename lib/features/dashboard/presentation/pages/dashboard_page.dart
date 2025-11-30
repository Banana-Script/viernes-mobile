import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../../shared/widgets/viernes_circular_icon_button.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/sentiment_chart.dart';
import '../widgets/categories_chart.dart';
import '../widgets/ai_human_chart.dart';
import '../widgets/tags_chart.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize dashboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      if (provider.status == DashboardStatus.initial) {
        provider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with circular buttons
              _buildHeader(isDark),

              const SizedBox(height: 16),

              // Tab bar with glassmorphism
              _buildTabBar(isDark),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: provider_pkg.Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                    if (provider.status == DashboardStatus.error) {
                      return _buildErrorWidget(provider);
                    }

                    return SmartRefresher(
                      controller: _refreshController,
                      onRefresh: () => _onRefresh(provider),
                      header: WaterDropMaterialHeader(
                        backgroundColor: isDark ? ViernesColors.accent : ViernesColors.secondary,
                        color: Colors.black,
                        distance: 60,
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(provider),
                          _buildAnalyticsTab(provider),
                          _buildInsightsTab(provider),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return provider_pkg.Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final organizationName = authProvider.organizationName ?? AppStrings.dashboard;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Stack(
            children: [
              // Centered title - Organization name
              Center(
                child: Text(
                  organizationName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Right-side buttons
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    // Export button
                    Semantics(
                      label: AppStrings.exportDataButton,
                      button: true,
                      child: ViernesCircularIconButton(
                        onTap: () => _showExportDialog(context),
                        child: Icon(
                          Icons.download,
                          color: isDark ? ViernesColors.accent : ViernesColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
              : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: isDark ? ViernesColors.accent : ViernesColors.primary,
        unselectedLabelColor: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              ViernesColors.secondary.withValues(alpha: 0.7),
              ViernesColors.accent.withValues(alpha: 0.7),
            ],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: ViernesTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: ViernesTextStyles.bodyText,
        tabs: const [
          Tab(text: AppStrings.overview),
          Tab(text: AppStrings.analytics),
          Tab(text: AppStrings.insights),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(DashboardProvider provider) {
    final isLoading = provider.status == DashboardStatus.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsCards(provider, isLoading),
          const SizedBox(height: 16),
          AiHumanChart(
            stats: provider.aiHumanStats,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(DashboardProvider provider) {
    final isLoading = provider.status == DashboardStatus.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SentimentChart(
            sentiments: provider.monthlyStats?.sentiments ?? {},
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),
          CategoriesChart(
            categories: provider.monthlyStats?.topCategories ?? {},
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(DashboardProvider provider) {
    final isLoading = provider.status == DashboardStatus.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TagsChart(
            tags: provider.monthlyStats?.tags ?? {},
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),
          _buildAdvisorsBreakdown(provider, isLoading, ref.watch(isDarkModeProvider)),
        ],
      ),
    );
  }

  Widget _buildStatsCards(DashboardProvider provider, bool isLoading) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        Semantics(
          label: '${AppStrings.totalInteractions}: ${isLoading ? '...' : (provider.monthlyStats?.interactions.toString() ?? '0')}',
          value: AppStrings.thisMonth,
          child: ViernesStatsCard(
            title: AppStrings.totalInteractions,
            value: isLoading ? '...' : (provider.monthlyStats?.interactions.toString() ?? '0'),
            subtitle: AppStrings.thisMonth,
            icon: Icons.chat_bubble_outline,
            isPrimary: true,
            isLoading: isLoading,
          ),
        ),
        Semantics(
          label: '${AppStrings.uniqueAttendees}: ${isLoading ? '...' : (provider.monthlyStats?.attendees.toString() ?? '0')}',
          value: AppStrings.activeUsers,
          child: ViernesStatsCard(
            title: AppStrings.uniqueAttendees,
            value: isLoading ? '...' : (provider.monthlyStats?.attendees.toString() ?? '0'),
            subtitle: AppStrings.activeUsers,
            icon: Icons.people_outline,
            accentColor: ViernesColors.success,
            isLoading: isLoading,
          ),
        ),
        Semantics(
          label: '${AppStrings.aiConversations}: ${isLoading ? '...' : '${provider.monthlyStats?.aiPercentage.toStringAsFixed(1) ?? '0'}%'}',
          value: '${provider.monthlyStats?.aiOnlyConversations ?? 0} ${AppStrings.conversations}',
          child: ViernesStatsCard(
            title: AppStrings.aiConversations,
            value: isLoading
                ? '...'
                : '${provider.monthlyStats?.aiPercentage.toStringAsFixed(1) ?? '0'}%',
            subtitle: '${provider.monthlyStats?.aiOnlyConversations ?? 0} ${AppStrings.conversations}',
            icon: Icons.smart_toy_outlined,
            accentColor: ViernesColors.accent,
            isLoading: isLoading,
          ),
        ),
        Semantics(
          label: '${AppStrings.humanAssisted}: ${isLoading ? '...' : '${provider.monthlyStats?.humanPercentage.toStringAsFixed(1) ?? '0'}%'}',
          value: '${provider.monthlyStats?.humanAssistedConversations ?? 0} ${AppStrings.conversations}',
          child: ViernesStatsCard(
            title: AppStrings.humanAssisted,
            value: isLoading
                ? '...'
                : '${provider.monthlyStats?.humanPercentage.toStringAsFixed(1) ?? '0'}%',
            subtitle: '${provider.monthlyStats?.humanAssistedConversations ?? 0} ${AppStrings.conversations}',
            icon: Icons.support_agent_outlined,
            accentColor: ViernesColors.warning,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvisorsBreakdown(DashboardProvider provider, bool isLoading, bool isDark) {
    final advisors = provider.aiHumanStats?.advisors ?? [];

    return ViernesGlassmorphismCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.topAdvisors,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: isDark ? ViernesColors.accent : ViernesColors.primary,
                  strokeWidth: 3,
                ),
              ),
            )
          else if (advisors.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  AppStrings.noAdvisorData,
                  style: ViernesTextStyles.bodyText.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else
            ...advisors.take(5).map((advisor) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                          .withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar with gradient
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ViernesColors.secondary.withValues(alpha: 0.6),
                              ViernesColors.accent.withValues(alpha: 0.6),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            advisor.name.isNotEmpty ? advisor.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          advisor.name,
                          style: ViernesTextStyles.bodyText.copyWith(
                            color: ViernesColors.getTextColor(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ViernesColors.secondary.withValues(alpha: 0.2),
                              ViernesColors.accent.withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          advisor.conversationCount.toString(),
                          style: ViernesTextStyles.bodySmall.copyWith(
                            color: isDark ? ViernesColors.accent : ViernesColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(DashboardProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ViernesGlassmorphismCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon with gradient background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ViernesColors.danger.withValues(alpha: 0.2),
                      ViernesColors.warning.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: ViernesColors.danger,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                AppStrings.failedToLoadDashboard,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ViernesColors.getTextColor(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                provider.errorMessage ?? AppStrings.unexpectedError,
                style: ViernesTextStyles.bodyText.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              ViernesGradientButton(
                text: AppStrings.retry,
                onPressed: () => provider.retry(),
                isLoading: false,
                width: 200,
                borderRadius: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh(DashboardProvider provider) async {
    await provider.refresh();
    _refreshController.refreshCompleted();
  }

  void _showExportDialog(BuildContext context) {
    final provider = context.read<DashboardProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ViernesGlassmorphismCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ViernesColors.secondary.withValues(alpha: 0.3),
                      ViernesColors.accent.withValues(alpha: 0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.download,
                  size: 32,
                  color: isDark ? ViernesColors.accent : ViernesColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                AppStrings.exportDataTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ViernesColors.getTextColor(isDark),
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Text(
                AppStrings.exportDataMessage,
                style: ViernesTextStyles.bodyText.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                              .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              AppStrings.cancel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ViernesColors.getTextColor(isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ViernesGradientButton(
                      text: AppStrings.export,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final csvData = await provider.exportConversationStats();
                        if (csvData != null && context.mounted) {
                          _showSuccessSnackBar(context, AppStrings.exportSuccess);
                        } else if (context.mounted) {
                          _showErrorSnackBar(
                            context,
                            provider.errorMessage ?? AppStrings.exportFailed,
                          );
                        }
                      },
                      isLoading: false,
                      height: 48,
                      borderRadius: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ViernesColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ViernesColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
