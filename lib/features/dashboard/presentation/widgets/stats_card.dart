import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Viernes Stats Card
///
/// Unified stats card with glassmorphism effect and improved visual design.
/// Features:
/// - Glassmorphism styling with inner glow effect
/// - Support for gradient accent on primary cards
/// - Color-coded icons with subtle backgrounds
/// - Loading state with shimmer effect
/// - Haptic feedback on tap
/// - Optimized dark mode variants
///
/// Usage:
/// ```dart
/// ViernesStatsCard(
///   title: 'Total Interactions',
///   value: '1,234',
///   subtitle: 'This month',
///   icon: Icons.chat_bubble_outline,
///   isPrimary: true,  // Uses gradient accent
/// )
/// ```
class ViernesStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool isPrimary;

  const ViernesStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.isLoading = false,
    this.onTap,
    this.isPrimary = false,
  });

  @override
  State<ViernesStatsCard> createState() => _ViernesStatsCardState();
}

class _ViernesStatsCardState extends State<ViernesStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultAccent = widget.accentColor ??
        (isDark ? ViernesColors.accent : ViernesColors.primary);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: ViernesGlassmorphismCard(
          borderRadius: 16,
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Inner glow effect for primary cards
              border: widget.isPrimary
                  ? Border.all(
                      color: isDark
                          ? ViernesColors.accent.withValues(alpha: 0.25)
                          : ViernesColors.primary.withValues(alpha: 0.15),
                      width: 1.5,
                    )
                  : Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      width: 1,
                    ),
              // Subtle inner glow
              boxShadow: widget.isPrimary && isDark
                  ? [
                      BoxShadow(
                        color: ViernesColors.accent.withValues(alpha: 0.08),
                        blurRadius: 12,
                        spreadRadius: -2,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.isLoading
                  ? _buildLoadingContent(isDark)
                  : _buildContent(isDark, defaultAccent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 28,
          width: 80,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(bool isDark, Color accentColor) {
    // Determine value color based on priority and theme
    final valueColor = widget.isPrimary
        ? (isDark ? ViernesColors.accent : ViernesColors.primary)
        : accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Header: Title and Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Icon with gradient background if primary
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: widget.isPrimary
                    ? LinearGradient(
                        colors: isDark
                            ? [
                                ViernesColors.accent.withValues(alpha: 0.25),
                                ViernesColors.accent.withValues(alpha: 0.1),
                              ]
                            : [
                                ViernesColors.primary.withValues(alpha: 0.15),
                                ViernesColors.primary.withValues(alpha: 0.05),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isPrimary ? null : accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
                border: widget.isPrimary
                    ? Border.all(
                        color: isDark
                            ? ViernesColors.accent.withValues(alpha: 0.2)
                            : ViernesColors.primary.withValues(alpha: 0.1),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: widget.isPrimary
                    ? (isDark ? ViernesColors.accent : ViernesColors.primary)
                    : accentColor,
                size: 20,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Value with optional badge styling for primary
        widget.isPrimary
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: valueColor.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.value,
                  style: ViernesTextStyles.h3.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(
                widget.value,
                style: ViernesTextStyles.h3.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

        // Subtitle
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 14,
                color: ViernesColors.success.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.subtitle!,
                  style: ViernesTextStyles.caption.copyWith(
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Keep old classes for backward compatibility (deprecated)
@Deprecated('Use ViernesStatsCard instead')
class StatsCard extends ViernesStatsCard {
  const StatsCard({
    super.key,
    required super.title,
    required super.value,
    super.subtitle,
    IconData? icon,
    Color? color,
    Color? backgroundColor,
    super.isLoading,
    super.onTap,
  }) : super(
          icon: icon ?? Icons.analytics,
          accentColor: color,
        );
}

@Deprecated('Use ViernesStatsCard with isPrimary: true instead')
class GradientStatsCard extends ViernesStatsCard {
  const GradientStatsCard({
    super.key,
    required super.title,
    required super.value,
    super.subtitle,
    IconData? icon,
    LinearGradient? gradient,
    super.isLoading,
    super.onTap,
  }) : super(
          icon: icon ?? Icons.analytics,
          isPrimary: true,
        );
}
