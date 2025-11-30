import 'package:flutter/material.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../viernes_glassmorphism_card.dart';

/// Preset types for skeleton card layouts
enum ViernesSkeletonPreset {
  /// Customer card skeleton layout
  customer,

  /// Conversation card skeleton layout
  conversation,

  /// Generic card skeleton layout
  generic,
}

/// Viernes List Skeleton Widget
///
/// Displays animated skeleton placeholders while list data is loading.
/// Supports presets for different card layouts or custom card builders.
///
/// Features:
/// - Shimmer animation effect
/// - Multiple preset layouts (customer, conversation, generic)
/// - Custom card builder support
/// - Theme-aware colors (light/dark mode)
class ViernesListSkeleton extends StatefulWidget {
  /// Number of skeleton cards to display
  final int itemCount;

  /// Duration of the shimmer animation cycle
  final Duration animationDuration;

  /// Minimum opacity for shimmer animation
  final double minOpacity;

  /// Maximum opacity for shimmer animation
  final double maxOpacity;

  /// Preset layout type (if null, uses generic)
  final ViernesSkeletonPreset preset;

  /// Custom card builder (overrides preset if provided)
  final Widget Function(BuildContext context, Animation<double> animation)?
      cardBuilder;

  /// Padding for the list
  final EdgeInsets? padding;

  const ViernesListSkeleton({
    super.key,
    this.itemCount = 5,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.minOpacity = 0.3,
    this.maxOpacity = 0.7,
    this.preset = ViernesSkeletonPreset.generic,
    this.cardBuilder,
    this.padding,
  });

  @override
  State<ViernesListSkeleton> createState() => _ViernesListSkeletonState();
}

class _ViernesListSkeletonState extends State<ViernesListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(
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
      padding: widget.padding ?? const EdgeInsets.all(ViernesSpacing.md),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => _buildCard(),
    );
  }

  Widget _buildCard() {
    if (widget.cardBuilder != null) {
      return widget.cardBuilder!(context, _animation);
    }

    switch (widget.preset) {
      case ViernesSkeletonPreset.customer:
        return _CustomerSkeletonCard(animation: _animation);
      case ViernesSkeletonPreset.conversation:
        return _ConversationSkeletonCard(animation: _animation);
      case ViernesSkeletonPreset.generic:
        return _GenericSkeletonCard(animation: _animation);
    }
  }
}

/// Shimmer box helper widget
class ViernesShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final Animation<double> animation;
  final double borderRadius;

  const ViernesShimmerBox({
    super.key,
    required this.width,
    required this.height,
    required this.animation,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: animation.value * 0.3),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Customer skeleton card layout
class _CustomerSkeletonCard extends StatelessWidget {
  final Animation<double> animation;

  const _CustomerSkeletonCard({required this.animation});

  @override
  Widget build(BuildContext context) {
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
                  animation: animation,
                  builder: (context, child) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: animation.value * 0.3),
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
                      ViernesShimmerBox(
                        width: 150,
                        height: 16,
                        animation: animation,
                      ),
                      const SizedBox(height: 6),
                      ViernesShimmerBox(
                        width: 100,
                        height: 12,
                        animation: animation,
                      ),
                    ],
                  ),
                ),

                // Badges skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ViernesShimmerBox(
                      width: 60,
                      height: 20,
                      animation: animation,
                      borderRadius: ViernesSpacing.radiusLg,
                    ),
                    const SizedBox(height: ViernesSpacing.xs),
                    ViernesShimmerBox(
                      width: 60,
                      height: 20,
                      animation: animation,
                      borderRadius: ViernesSpacing.radiusLg,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Divider
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Container(
                height: 1,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: animation.value * 0.2),
              ),
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Contact info skeleton
            ViernesShimmerBox(
              width: double.infinity,
              height: 14,
              animation: animation,
            ),
            const SizedBox(height: ViernesSpacing.xs),
            ViernesShimmerBox(
              width: double.infinity,
              height: 14,
              animation: animation,
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Dates skeleton
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ViernesShimmerBox(
                        width: 60,
                        height: 10,
                        animation: animation,
                      ),
                      const SizedBox(height: 4),
                      ViernesShimmerBox(
                        width: 80,
                        height: 12,
                        animation: animation,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ViernesShimmerBox(
                        width: 70,
                        height: 10,
                        animation: animation,
                      ),
                      const SizedBox(height: 4),
                      ViernesShimmerBox(
                        width: 90,
                        height: 12,
                        animation: animation,
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
}

/// Conversation skeleton card layout
class _ConversationSkeletonCard extends StatelessWidget {
  final Animation<double> animation;

  const _ConversationSkeletonCard({required this.animation});

  @override
  Widget build(BuildContext context) {
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
                  animation: animation,
                  builder: (context, child) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: animation.value * 0.3),
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
                            child: ViernesShimmerBox(
                              width: double.infinity,
                              height: 16,
                              animation: animation,
                            ),
                          ),
                          const SizedBox(width: ViernesSpacing.xs),
                          ViernesShimmerBox(
                            width: 30,
                            height: 11,
                            animation: animation,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Channel and agent info skeleton
                      ViernesShimmerBox(
                        width: 150,
                        height: 11,
                        animation: animation,
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
                ViernesShimmerBox(
                  width: 60,
                  height: 20,
                  animation: animation,
                  borderRadius: ViernesSpacing.radiusLg,
                ),
                const SizedBox(width: ViernesSpacing.xs),
                ViernesShimmerBox(
                  width: 55,
                  height: 20,
                  animation: animation,
                  borderRadius: ViernesSpacing.radiusLg,
                ),
                const SizedBox(width: ViernesSpacing.xs),
                ViernesShimmerBox(
                  width: 70,
                  height: 20,
                  animation: animation,
                  borderRadius: ViernesSpacing.radiusLg,
                ),
              ],
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Divider
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) => Container(
                height: 1,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: animation.value * 0.2),
              ),
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Message preview skeleton
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon placeholder
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: animation.value * 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ViernesShimmerBox(
                        width: double.infinity,
                        height: 12,
                        animation: animation,
                      ),
                      const SizedBox(height: 4),
                      ViernesShimmerBox(
                        width: 200,
                        height: 12,
                        animation: animation,
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
}

/// Generic skeleton card layout
class _GenericSkeletonCard extends StatelessWidget {
  final Animation<double> animation;

  const _GenericSkeletonCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
      child: ViernesGlassmorphismCard(
        borderRadius: ViernesSpacing.radiusXxl,
        padding: const EdgeInsets.all(ViernesSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar skeleton
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: animation.value * 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ViernesShimmerBox(
                        width: 150,
                        height: 16,
                        animation: animation,
                      ),
                      const SizedBox(height: 6),
                      ViernesShimmerBox(
                        width: 100,
                        height: 12,
                        animation: animation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ViernesSpacing.md),
            ViernesShimmerBox(
              width: double.infinity,
              height: 14,
              animation: animation,
            ),
            const SizedBox(height: ViernesSpacing.xs),
            ViernesShimmerBox(
              width: 200,
              height: 14,
              animation: animation,
            ),
          ],
        ),
      ),
    );
  }
}
