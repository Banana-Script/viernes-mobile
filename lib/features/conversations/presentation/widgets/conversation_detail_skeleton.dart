import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';

/// Conversation Detail Loading Skeleton
///
/// Displays animated skeleton placeholders while conversation detail is loading.
/// Mimics the chat interface layout with:
/// - Status bar skeleton
/// - Message bubble skeletons (alternating sides)
/// - Composer skeleton
class ConversationDetailSkeleton extends StatefulWidget {
  const ConversationDetailSkeleton({super.key});

  @override
  State<ConversationDetailSkeleton> createState() =>
      _ConversationDetailSkeletonState();
}

class _ConversationDetailSkeletonState extends State<ConversationDetailSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Pre-defined bubble configurations for consistent layout
  static const List<_BubbleConfig> _bubbleConfigs = [
    _BubbleConfig(isUser: true, widthFactor: 0.65, heightFactor: 1.0),
    _BubbleConfig(isUser: false, widthFactor: 0.55, heightFactor: 1.2),
    _BubbleConfig(isUser: false, widthFactor: 0.7, heightFactor: 0.8),
    _BubbleConfig(isUser: true, widthFactor: 0.5, heightFactor: 1.5),
    _BubbleConfig(isUser: false, widthFactor: 0.6, heightFactor: 1.0),
  ];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Status bar skeleton
        _buildStatusBarSkeleton(isDark),

        // Messages area skeleton
        Expanded(
          child: ListView(
            reverse: true,
            padding: const EdgeInsets.symmetric(
              vertical: ViernesSpacing.lg,
              horizontal: ViernesSpacing.md,
            ),
            children: _bubbleConfigs
                .map((config) => _buildMessageBubbleSkeleton(
                      isDark: isDark,
                      isUser: config.isUser,
                      widthFactor: config.widthFactor,
                      heightFactor: config.heightFactor,
                    ))
                .toList(),
          ),
        ),

        // Composer skeleton
        _buildComposerSkeleton(isDark),
      ],
    );
  }

  Widget _buildStatusBarSkeleton(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        border: Border(
          bottom: BorderSide(
            color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status badge skeleton
          _buildShimmerBox(
            width: 80,
            height: 24,
            isDark: isDark,
            borderRadius: 12,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          // Priority badge skeleton
          _buildShimmerBox(
            width: 60,
            height: 24,
            isDark: isDark,
            borderRadius: 12,
          ),
          const Spacer(),
          // Assigned agent skeleton
          _buildShimmerBox(
            width: 120,
            height: 14,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubbleSkeleton({
    required bool isDark,
    required bool isUser,
    required double widthFactor,
    required double heightFactor,
  }) {
    const baseWidth = 180.0;
    const baseHeight = 50.0;
    final width = baseWidth * widthFactor;
    final height = baseHeight * heightFactor;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
          bottom: ViernesSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Bubble container
            _buildShimmerBox(
              width: width,
              height: height,
              isDark: isDark,
              borderRadius: 16,
            ),
            const SizedBox(height: 4),
            // Timestamp skeleton
            _buildShimmerBox(
              width: 50,
              height: 10,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposerSkeleton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        border: Border(
          top: BorderSide(
            color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment button skeleton
            _buildShimmerBox(
              width: 40,
              height: 40,
              isDark: isDark,
              borderRadius: 20,
            ),
            const SizedBox(width: ViernesSpacing.sm),
            // Text field skeleton
            Expanded(
              child: _buildShimmerBox(
                width: double.infinity,
                height: 44,
                isDark: isDark,
                borderRadius: 22,
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            // Send button skeleton
            _buildShimmerBox(
              width: 40,
              height: 40,
              isDark: isDark,
              borderRadius: 20,
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

/// Configuration for a skeleton bubble
class _BubbleConfig {
  final bool isUser;
  final double widthFactor;
  final double heightFactor;

  const _BubbleConfig({
    required this.isUser,
    required this.widthFactor,
    required this.heightFactor,
  });
}
