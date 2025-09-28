import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/sentiment_chart.dart';
import '../widgets/categories_chart.dart';
import '../widgets/ai_human_chart.dart';
import '../widgets/tags_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      body: Column(
        children: [
          // Custom header
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ViernesSpacing.md,
                vertical: ViernesSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dashboard',
                      style: ViernesTextStyles.h3.copyWith(
                        color: ViernesColors.getTextColor(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showExportDialog(context),
                    icon: Icon(
                      Icons.download,
                      color: ViernesColors.getThemePrimary(isDark),
                    ),
                    tooltip: 'Export Data',
                  ),
                ],
              ),
            ),
          ),
          // Tab bar
          Container(
            color: ViernesColors.getControlBackground(isDark),
            child: TabBar(
              controller: _tabController,
              labelColor: ViernesColors.getThemePrimary(isDark),
              unselectedLabelColor: ViernesColors.getTextColor(isDark).withValues(alpha:0.6),
              indicatorColor: ViernesColors.getThemePrimary(isDark),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Analytics'),
                Tab(text: 'Insights'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Consumer<DashboardProvider>(
              builder: (context, provider, child) {
                if (provider.status == DashboardStatus.error) {
                  return _buildErrorWidget(provider);
                }

                return SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () => _onRefresh(provider),
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
    );
  }

  Widget _buildOverviewTab(DashboardProvider provider) {
    final isLoading = provider.status == DashboardStatus.loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        children: [
          _buildStatsCards(provider, isLoading),
          const SizedBox(height: ViernesSpacing.md),
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
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        children: [
          SentimentChart(
            sentiments: provider.monthlyStats?.sentiments ?? {},
            isLoading: isLoading,
          ),
          const SizedBox(height: ViernesSpacing.md),
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
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        children: [
          TagsChart(
            tags: provider.monthlyStats?.tags ?? {},
            isLoading: isLoading,
          ),
          const SizedBox(height: ViernesSpacing.md),
          _buildAdvisorsBreakdown(provider, isLoading),
        ],
      ),
    );
  }

  Widget _buildStatsCards(DashboardProvider provider, bool isLoading) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      crossAxisSpacing: ViernesSpacing.md,
      mainAxisSpacing: ViernesSpacing.md,
      children: [
        GradientStatsCard(
          title: 'Total Interactions',
          value: isLoading ? '...' : (provider.monthlyStats?.interactions.toString() ?? '0'),
          subtitle: 'This month',
          icon: Icons.chat_bubble_outline,
          isLoading: isLoading,
        ),
        StatsCard(
          title: 'Unique Attendees',
          value: isLoading ? '...' : (provider.monthlyStats?.attendees.toString() ?? '0'),
          subtitle: 'Active users',
          icon: Icons.people_outline,
          color: ViernesColors.success,
          isLoading: isLoading,
        ),
        StatsCard(
          title: 'AI Conversations',
          value: isLoading
              ? '...'
              : '${provider.monthlyStats?.aiPercentage.toStringAsFixed(1) ?? '0'}%',
          subtitle: '${provider.monthlyStats?.aiOnlyConversations ?? 0} conversations',
          icon: Icons.smart_toy_outlined,
          color: ViernesColors.accent,
          isLoading: isLoading,
        ),
        StatsCard(
          title: 'Human Assisted',
          value: isLoading
              ? '...'
              : '${provider.monthlyStats?.humanPercentage.toStringAsFixed(1) ?? '0'}%',
          subtitle: '${provider.monthlyStats?.humanAssistedConversations ?? 0} conversations',
          icon: Icons.support_agent_outlined,
          color: ViernesColors.warning,
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildAdvisorsBreakdown(DashboardProvider provider, bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final advisors = provider.aiHumanStats?.advisors ?? [];

    return Card(
      elevation: 2,
      color: ViernesColors.getControlBackground(isDark),
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Advisors',
              style: ViernesTextStyles.h3.copyWith(
                color: ViernesColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ViernesSpacing.md),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ViernesColors.primary),
                ),
              )
            else if (advisors.isEmpty)
              Center(
                child: Text(
                  'No advisor data available',
                  style: ViernesTextStyles.bodyText.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha:0.6),
                  ),
                ),
              )
            else
              ...advisors.take(5).map((advisor) => Padding(
                    padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: ViernesColors.getThemePrimary(isDark),
                          child: Text(
                            advisor.name.isNotEmpty ? advisor.name[0].toUpperCase() : '?',
                            style: ViernesTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: ViernesSpacing.sm),
                        Expanded(
                          child: Text(
                            advisor.name,
                            style: ViernesTextStyles.bodyText.copyWith(
                              color: ViernesColors.getTextColor(isDark),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ViernesSpacing.sm,
                            vertical: ViernesSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: ViernesColors.getThemePrimary(isDark).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            advisor.conversationCount.toString(),
                            style: ViernesTextStyles.caption.copyWith(
                              color: ViernesColors.getThemePrimary(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(DashboardProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: ViernesColors.danger,
            ),
            const SizedBox(height: ViernesSpacing.md),
            Text(
              'Failed to load dashboard',
              style: ViernesTextStyles.h3.copyWith(
                color: ViernesColors.getTextColor(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              provider.errorMessage ?? 'An unexpected error occurred',
              style: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha:0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ViernesSpacing.lg),
            ElevatedButton(
              onPressed: () => provider.retry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ViernesColors.getThemePrimary(isDark),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export conversation statistics as CSV?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final csvData = await provider.exportConversationStats();
              if (csvData != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data exported successfully'),
                    backgroundColor: ViernesColors.success,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Export failed'),
                    backgroundColor: ViernesColors.danger,
                  ),
                );
              }
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}