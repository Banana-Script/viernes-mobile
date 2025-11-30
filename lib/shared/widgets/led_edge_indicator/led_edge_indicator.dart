import 'package:flutter/material.dart';
import 'led_indicator_models.dart';

/// LED Edge Indicator Widget
///
/// Displays elegant LED-style edge indicators on the sides of the screen
/// to show agent availability status (active/inactive).
///
/// Features:
/// - Dual vertical bars on left and right edges
/// - Smooth gradient with LED diffusion effect
/// - Breathing animation (optional)
/// - Theme-aware colors (light/dark mode)
/// - Non-intrusive (IgnorePointer)
/// - Performance optimized (RepaintBoundary)
class LedEdgeIndicator extends StatefulWidget {
  /// Whether the agent is currently active/available
  final bool isActive;

  /// Configuration for the LED indicator appearance and behavior
  final LedIndicatorConfig config;

  /// The variant style of the LED indicator
  final LedIndicatorVariant variant;

  const LedEdgeIndicator({
    super.key,
    required this.isActive,
    this.config = LedIndicatorConfig.defaultConfig,
    this.variant = LedIndicatorVariant.dualVertical,
  });

  @override
  State<LedEdgeIndicator> createState() => _LedEdgeIndicatorState();
}

class _LedEdgeIndicatorState extends State<LedEdgeIndicator>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause animation when app goes to background to save battery
    if (state == AppLifecycleState.paused && widget.config.enableAnimation) {
      _animationController.stop();
    } else if (state == AppLifecycleState.resumed && widget.config.enableAnimation) {
      _animationController.repeat(reverse: true);
    }
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.config.minOpacity,
      end: widget.config.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.config.enableAnimation) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LedEdgeIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation if config changed
    if (oldWidget.config.enableAnimation != widget.config.enableAnimation) {
      if (widget.config.enableAnimation) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case LedIndicatorVariant.dualVertical:
        return _buildDualVerticalBars();
      case LedIndicatorVariant.singleAccent:
        return _buildSingleAccentBar();
      case LedIndicatorVariant.horizontalBars:
        return _buildHorizontalBars();
      case LedIndicatorVariant.fullFrame:
        return _buildFullFrame();
    }
  }

  /// Build dual vertical bars on left and right edges
  Widget _buildDualVerticalBars() {
    return Stack(
      children: [
        // Left edge bar
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: _buildVerticalBar(isLeftSide: true),
        ),
        // Right edge bar
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: _buildVerticalBar(isLeftSide: false),
        ),
      ],
    );
  }

  /// Build single accent bar on left edge
  Widget _buildSingleAccentBar() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: _buildVerticalBar(isLeftSide: true),
    );
  }

  /// Build horizontal bars on top and bottom edges
  Widget _buildHorizontalBars() {
    return Stack(
      children: [
        // Top edge bar
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: _buildHorizontalBar(isTop: true),
          ),
        ),
        // Bottom edge bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildHorizontalBar(isTop: false),
        ),
      ],
    );
  }

  /// Build full frame with all four edges
  Widget _buildFullFrame() {
    return Stack(
      children: [
        // Top bar
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: _buildHorizontalBar(isTop: true),
          ),
        ),
        // Bottom bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildHorizontalBar(isTop: false),
        ),
        // Left bar
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: _buildVerticalBar(isLeftSide: true),
        ),
        // Right bar
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: _buildVerticalBar(isLeftSide: false),
        ),
      ],
    );
  }

  /// Build a vertical LED bar
  Widget _buildVerticalBar({required bool isLeftSide}) {
    final color = LedIndicatorColors.getLedColor(context, widget.isActive);

    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            final opacity = widget.config.enableAnimation
                ? _opacityAnimation.value
                : widget.config.maxOpacity;

            return Container(
              width: widget.config.edgeWidth,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity * 0.9),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: widget.config.glowBlurRadius,
                    spreadRadius: widget.config.glowSpreadRadius,
                    offset: Offset.zero,
                  ),
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: widget.config.diffusionBlurRadius,
                    spreadRadius: widget.config.glowSpreadRadius * 2,
                    offset: Offset.zero,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build a horizontal LED bar
  Widget _buildHorizontalBar({required bool isTop}) {
    final color = LedIndicatorColors.getLedColor(context, widget.isActive);

    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _opacityAnimation,
          builder: (context, child) {
            final opacity = widget.config.enableAnimation
                ? _opacityAnimation.value
                : widget.config.maxOpacity;

            return Container(
              height: widget.config.edgeWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  colors: [
                    color.withValues(alpha: 0.0),
                    color.withValues(alpha: opacity * 0.5),
                    color.withValues(alpha: opacity * 0.9),
                    color.withValues(alpha: opacity * 0.5),
                    color.withValues(alpha: 0.0),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: opacity * 0.4),
                    blurRadius: widget.config.glowBlurRadius,
                    spreadRadius: widget.config.glowSpreadRadius,
                    offset: Offset(0, isTop ? 2 : -2),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
