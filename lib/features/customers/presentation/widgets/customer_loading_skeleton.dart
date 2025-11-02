import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Customer Loading Skeleton Widget
///
/// Displays animated skeleton placeholders while customer data is loading.
/// Features:
/// - Shimmer animation effect
/// - Matches CustomerCard layout
/// - Multiple skeleton cards
class CustomerLoadingSkeleton extends StatefulWidget {
  final int itemCount;

  const CustomerLoadingSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  State<CustomerLoadingSkeleton> createState() =>
      _CustomerLoadingSkeletonState();
}

class _CustomerLoadingSkeletonState extends State<CustomerLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
      child: ViernesGlassmorphismCard(
        borderRadius: ViernesSpacing.radiusXxl,
        padding: const EdgeInsets.all(ViernesSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar and name area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar skeleton
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: _animation.value * 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.space3),

                // Name and agent skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(
                        width: 150,
                        height: 16,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      _buildShimmerBox(
                        width: 100,
                        height: 12,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Badges skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildShimmerBox(
                      width: 60,
                      height: 20,
                      isDark: isDark,
                      borderRadius: ViernesSpacing.radiusLg,
                    ),
                    const SizedBox(height: ViernesSpacing.xs),
                    _buildShimmerBox(
                      width: 60,
                      height: 20,
                      isDark: isDark,
                      borderRadius: ViernesSpacing.radiusLg,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Divider
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Container(
                height: 1,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: _animation.value * 0.2),
              ),
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Contact info skeleton
            _buildShimmerBox(
              width: double.infinity,
              height: 14,
              isDark: isDark,
            ),
            const SizedBox(height: ViernesSpacing.xs),
            _buildShimmerBox(
              width: double.infinity,
              height: 14,
              isDark: isDark,
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Dates skeleton
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(
                        width: 60,
                        height: 10,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      _buildShimmerBox(
                        width: 80,
                        height: 12,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(
                        width: 70,
                        height: 10,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      _buildShimmerBox(
                        width: 90,
                        height: 12,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required bool isDark,
    double borderRadius = 4,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: _animation.value * 0.3),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
