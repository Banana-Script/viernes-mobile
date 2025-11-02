import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../agent_status_indicator.dart';

/// Agent Status Demo Page
///
/// A demo page showcasing all available agent status indicator variants.
/// This page is useful for:
/// - Viewing all design options
/// - Testing different states (active/inactive)
/// - Comparing visual styles
/// - Testing in light/dark mode
class AgentStatusDemoPage extends StatefulWidget {
  const AgentStatusDemoPage({super.key});

  @override
  State<AgentStatusDemoPage> createState() => _AgentStatusDemoPageState();
}

class _AgentStatusDemoPageState extends State<AgentStatusDemoPage> {
  bool _isActive = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Status Indicator Demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        children: [
          // Status Toggle
          _buildStatusToggle(),
          const SizedBox(height: ViernesSpacing.xl),

          // Current Status Info
          _buildCurrentStatusCard(isDark),
          const SizedBox(height: ViernesSpacing.xl),

          // Variant 1: Top Bar
          _buildVariantSection(
            title: 'Variant 1: Top Bar',
            description:
                'Thin colored bar at the top of the screen. Minimal and subtle.',
            pros: [
              'Very minimal, doesn\'t take screen space',
              'Clear visual feedback',
              'Works well in all contexts',
            ],
            cons: [
              'Might be too subtle for some users',
              'Limited information display',
            ],
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark
                    ? ViernesColors.panelDark
                    : ViernesColors.panelLight,
                borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                border: Border.all(
                  color: ViernesColors.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  AgentStatusIndicator(
                    isActive: _isActive,
                    variant: AgentStatusVariant.topBar,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Your app content here'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: ViernesSpacing.xl),

          // Variant 2: Glass Badge
          _buildVariantSection(
            title: 'Variant 2: Glass Badge',
            description:
                'Glassmorphism badge with icon and text. Modern and stylish.',
            pros: [
              'Clear status text',
              'Beautiful glassmorphism effect',
              'Subtle pulsing animation',
              'Can be placed in app bar',
            ],
            cons: [
              'Takes more horizontal space',
              'Might overlap with app bar actions',
            ],
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark
                    ? ViernesColors.panelDark
                    : ViernesColors.panelLight,
                borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                border: Border.all(
                  color: ViernesColors.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ViernesSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AgentStatusIndicator(
                          isActive: _isActive,
                          variant: AgentStatusVariant.glassBadge,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Your app content here'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: ViernesSpacing.xl),

          // Variant 3: Expandable Banner
          _buildVariantSection(
            title: 'Variant 3: Expandable Banner',
            description:
                'Full-width banner with expandable details. Most informative.',
            pros: [
              'Most information available',
              'Clear and prominent',
              'Expandable for more details',
              'Good for important notifications',
            ],
            cons: [
              'Takes vertical screen space',
              'More prominent (can be distracting)',
            ],
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark
                    ? ViernesColors.panelDark
                    : ViernesColors.panelLight,
                borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                border: Border.all(
                  color: ViernesColors.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  AgentStatusIndicator(
                    isActive: _isActive,
                    variant: AgentStatusVariant.expandableBanner,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Your app content here'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: ViernesSpacing.xl),

          // Variant 4: Floating Pill
          _buildVariantSection(
            title: 'Variant 4: Floating Pill',
            description:
                'Floating pill badge in the top-right corner. Clean and modern.',
            pros: [
              'Clean and modern look',
              'Doesn\'t interfere with content',
              'Easy to spot',
              'Nice shadow effects',
            ],
            cons: [
              'Might overlap with floating elements',
              'Position might vary per screen',
            ],
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark
                    ? ViernesColors.panelDark
                    : ViernesColors.panelLight,
                borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                border: Border.all(
                  color: ViernesColors.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Text('Your app content here'),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: AgentStatusIndicator(
                      isActive: _isActive,
                      variant: AgentStatusVariant.floatingPill,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: ViernesSpacing.xl),

          // Recommendations
          _buildRecommendations(isDark),

          const SizedBox(height: ViernesSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agent Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: ViernesSpacing.xs),
                Text(
                  _isActive ? 'Active (010)' : 'Inactive (020)',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isActive
                        ? ViernesColors.success
                        : ViernesColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Switch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: ViernesColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isActive ? Icons.check_circle : Icons.cancel,
                  color: _isActive ? ViernesColors.success : ViernesColors.danger,
                  size: 24,
                ),
                const SizedBox(width: ViernesSpacing.sm),
                Text(
                  _isActive ? 'Available for Customers' : 'Not Available',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ViernesSpacing.md),
            Text(
              _isActive
                  ? 'You are currently active and available to attend customers. The green indicator will be shown across all screens.'
                  : 'You are currently inactive. Customers cannot reach you. The red indicator will be shown across all screens.',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : ViernesColors.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSection({
    required String title,
    required String description,
    required List<String> pros,
    required List<String> cons,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.7)
                    : ViernesColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: ViernesSpacing.lg),
            child,
            const SizedBox(height: ViernesSpacing.lg),
            _buildProsCons(pros: pros, cons: cons, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProsCons({
    required List<String> pros,
    required List<String> cons,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: ViernesColors.success,
                  ),
                  SizedBox(width: ViernesSpacing.xs),
                  Text(
                    'Pros',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ViernesSpacing.xs),
              ...pros.map(
                (pro) => Padding(
                  padding: const EdgeInsets.only(
                    left: ViernesSpacing.md,
                    bottom: ViernesSpacing.xs,
                  ),
                  child: Text(
                    '• $pro',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : ViernesColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ViernesSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 16,
                    color: ViernesColors.warning,
                  ),
                  SizedBox(width: ViernesSpacing.xs),
                  Text(
                    'Cons',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ViernesSpacing.xs),
              ...cons.map(
                (con) => Padding(
                  padding: const EdgeInsets.only(
                    left: ViernesSpacing.md,
                    bottom: ViernesSpacing.xs,
                  ),
                  child: Text(
                    '• $con',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : ViernesColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(bool isDark) {
    return Card(
      color: ViernesColors.accent.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: ViernesColors.accent,
                  size: 24,
                ),
                SizedBox(width: ViernesSpacing.sm),
                Text(
                  'Recommendations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ViernesSpacing.md),
            _buildRecommendationItem(
              '1. Top Bar',
              'Best for minimal UI, doesn\'t interfere with content',
              Icons.star,
              isDark,
            ),
            _buildRecommendationItem(
              '2. Glass Badge',
              'Best for app bar integration, good balance of visibility and style',
              Icons.star,
              isDark,
            ),
            _buildRecommendationItem(
              '3. Floating Pill',
              'Best for modern apps with floating elements',
              Icons.star_half,
              isDark,
            ),
            _buildRecommendationItem(
              '4. Expandable Banner',
              'Best when status information is critical and needs emphasis',
              Icons.star_half,
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
    String title,
    String description,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: ViernesColors.secondary,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : ViernesColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
