import 'package:flutter/material.dart';

import '../../core/theme/viernes_colors.dart';

/// Constants for badge visual properties
class _BadgeConstants {
  static const double badgeSize = 8.0;
  static const double activeBlurRadius = 4.0;
  static const double inactiveBlurRadius = 2.0;
  static const double activeSpreadRadius = 1.0;
  static const double shadowOpacity = 0.4;
  static const Offset defaultOffset = Offset(12, 12);
  static const Duration animationDuration = Duration(milliseconds: 2000);
  static const Duration colorTransitionDuration = Duration(milliseconds: 300);
  static const double ringBorderWidth = 1.5;
  static const double ringSize = 12.0;
}

/// A minimalist animated status badge that shows agent activity status
///
/// Design Philosophy:
/// - Less invasive: Reduced size (8px vs 10px) with subtle opacity
/// - Smooth animations: Gentle pulse on active status for visual interest
/// - Elegant transitions: Animated color changes between states
/// - Contextual visibility: Only animates when active to avoid distraction
///
/// Visual Improvements:
/// - Smaller badge size (8px) for subtlety
/// - Soft shadow/glow effect for depth
/// - Breathing animation on active state (scale pulse)
/// - Smooth color transitions between active/inactive
/// - Semi-transparent background for elegance
class AnimatedStatusBadge extends StatefulWidget {
  /// The child widget to display the badge on (typically an Icon)
  final Widget child;

  /// Whether the agent is currently active
  final bool isActive;

  /// Optional custom offset for badge positioning
  /// Default: Offset(12, 12) - positioned at the left shoulder/hand of the icon
  final Offset? offset;

  const AnimatedStatusBadge({
    super.key,
    required this.child,
    required this.isActive,
    this.offset,
  });

  @override
  State<AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with 2-second duration
    // for a slow, calming pulse effect
    _animationController = AnimationController(
      duration: _BadgeConstants.animationDuration,
      vsync: this,
    );

    // Scale animation: subtle breathing effect (1.0 to 1.3)
    // Using a curved animation for more natural motion
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Opacity animation: gentle fade for the glow effect (0.7 to 1.0)
    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animation if active
    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle animation state changes when isActive changes
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeOffset = widget.offset ?? _BadgeConstants.defaultOffset;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main child widget (the icon)
        widget.child,

        // Animated status badge
        Positioned(
          left: badgeOffset.dx,
          top: badgeOffset.dy,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animationController,
              // Cache child to avoid rebuilding on every frame
              child: _BadgeDot(isActive: widget.isActive),
              builder: (context, child) {
                return Transform.scale(
                  // Only apply scale animation when active
                  scale: widget.isActive ? _scaleAnimation.value : 1.0,
                  child: Opacity(
                    // Only apply opacity animation when active
                    opacity: widget.isActive ? _opacityAnimation.value : 1.0,
                    child: child,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Separate widget for the badge dot with smooth color transitions
class _BadgeDot extends StatelessWidget {
  final bool isActive;

  const _BadgeDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? ViernesColors.success : ViernesColors.danger;

    return AnimatedContainer(
      duration: _BadgeConstants.colorTransitionDuration,
      curve: Curves.easeInOut,
      width: _BadgeConstants.badgeSize,
      height: _BadgeConstants.badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        // Subtle shadow for depth and visibility
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: _BadgeConstants.shadowOpacity),
            blurRadius: isActive
                ? _BadgeConstants.activeBlurRadius
                : _BadgeConstants.inactiveBlurRadius,
            spreadRadius:
                isActive ? _BadgeConstants.activeSpreadRadius : 0,
          ),
        ],
      ),
    );
  }
}

/// Alternative implementation with a ring pulse effect (more subtle)
///
/// This version shows a ripple/ring effect that expands outward
/// Can be used for an even more minimal approach
class AnimatedStatusBadgeRing extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Offset? offset;

  const AnimatedStatusBadgeRing({
    super.key,
    required this.child,
    required this.isActive,
    this.offset,
  });

  @override
  State<AnimatedStatusBadgeRing> createState() =>
      _AnimatedStatusBadgeRingState();
}

class _AnimatedStatusBadgeRingState extends State<AnimatedStatusBadgeRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedStatusBadgeRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeOffset = widget.offset ?? _BadgeConstants.defaultOffset;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          left: badgeOffset.dx,
          top: badgeOffset.dy,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              // Cache the dot to avoid rebuilding on every frame
              child: _BadgeDot(isActive: widget.isActive),
              builder: (context, dotChild) {
                return SizedBox(
                  width: _BadgeConstants.ringSize,
                  height: _BadgeConstants.ringSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated ring effect (only when active)
                      if (widget.isActive)
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Container(
                              width: _BadgeConstants.badgeSize,
                              height: _BadgeConstants.badgeSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ViernesColors.success,
                                  width: _BadgeConstants.ringBorderWidth,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Cached badge dot
                      dotChild!,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
