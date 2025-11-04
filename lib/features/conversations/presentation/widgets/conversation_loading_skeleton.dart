import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Conversation Loading Skeleton Widget
///
/// Displays animated skeleton placeholders while conversation data is loading.
/// Features:
/// - Shimmer animation effect
/// - Matches ConversationCard layout
/// - Multiple skeleton cards
class ConversationLoadingSkeleton extends StatefulWidget {
  final int itemCount;

  const ConversationLoadingSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  State<ConversationLoadingSkeleton> createState() =>
      _ConversationLoadingSkeletonState();
}

class _ConversationLoadingSkeletonState extends State<ConversationLoadingSkeleton>
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
      padding: const EdgeInsets.fromLTRB(
        ViernesSpacing.md,
        0,
        ViernesSpacing.md,
        ViernesSpacing.md,
      ),
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
            // Top row: Avatar, name, and time
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

                // Name and channel/agent info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and time row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildShimmerBox(
                              width: double.infinity,
                              height: 16,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: ViernesSpacing.xs),
                          _buildShimmerBox(
                            width: 30,
                            height: 11,
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Channel and agent info skeleton
                      _buildShimmerBox(
                        width: 150,
                        height: 11,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Badges row
            const SizedBox(height: ViernesSpacing.sm),
            Row(
              children: [
                _buildShimmerBox(
                  width: 60,
                  height: 20,
                  isDark: isDark,
                  borderRadius: ViernesSpacing.radiusLg,
                ),
                const SizedBox(width: ViernesSpacing.xs),
                _buildShimmerBox(
                  width: 55,
                  height: 20,
                  isDark: isDark,
                  borderRadius: ViernesSpacing.radiusLg,
                ),
                const SizedBox(width: ViernesSpacing.xs),
                _buildShimmerBox(
                  width: 70,
                  height: 20,
                  isDark: isDark,
                  borderRadius: ViernesSpacing.radiusLg,
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

            // Message preview skeleton
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon placeholder
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: _animation.value * 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(
                        width: double.infinity,
                        height: 12,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 4),
                      _buildShimmerBox(
                        width: 200,
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
