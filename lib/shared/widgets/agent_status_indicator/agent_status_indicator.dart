import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_spacing.dart';

/// Agent Status Indicator Widget
///
/// A global status indicator that shows the agent's availability status
/// across all screens of the app. Supports multiple visual variants.
///
/// The indicator displays:
/// - Active (010): Green indicator - Agent is available
/// - Inactive (020): Red indicator - Agent is not available
class AgentStatusIndicator extends StatelessWidget {
  final bool isActive;
  final AgentStatusVariant variant;
  final VoidCallback? onTap;

  const AgentStatusIndicator({
    super.key,
    required this.isActive,
    this.variant = AgentStatusVariant.topBar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AgentStatusVariant.topBar:
        return _TopBarIndicator(isActive: isActive, onTap: onTap);
      case AgentStatusVariant.glassBadge:
        return _GlassBadgeIndicator(isActive: isActive, onTap: onTap);
      case AgentStatusVariant.expandableBanner:
        return _ExpandableBannerIndicator(isActive: isActive, onTap: onTap);
      case AgentStatusVariant.floatingPill:
        return _FloatingPillIndicator(isActive: isActive, onTap: onTap);
    }
  }
}

/// Available visual variants for the status indicator
enum AgentStatusVariant {
  /// Thin bar at the top of the screen (minimal)
  topBar,

  /// Glass-morphism badge in the app bar
  glassBadge,

  /// Expandable banner with more information
  expandableBanner,

  /// Floating pill badge with pulse animation
  floatingPill,
}

// ============================================================================
// VARIANT 1: TOP BAR - Thin colored bar at the top
// ============================================================================
class _TopBarIndicator extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _TopBarIndicator({
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? ViernesColors.success : ViernesColors.danger;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 8,
        decoration: BoxDecoration(
          color: color,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0.5),
              color,
              color.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// VARIANT 2: GLASS BADGE - Glassmorphism badge with icon
// ============================================================================
class _GlassBadgeIndicator extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _GlassBadgeIndicator({
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive ? ViernesColors.success : ViernesColors.danger;
    final label = isActive ? 'Activo' : 'Inactivo';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.md,
          vertical: ViernesSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingDot(color: color, isActive: isActive),
            const SizedBox(width: ViernesSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : ViernesColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// VARIANT 3: EXPANDABLE BANNER - Banner with status information
// ============================================================================
class _ExpandableBannerIndicator extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _ExpandableBannerIndicator({
    required this.isActive,
    this.onTap,
  });

  @override
  State<_ExpandableBannerIndicator> createState() =>
      _ExpandableBannerIndicatorState();
}

class _ExpandableBannerIndicatorState
    extends State<_ExpandableBannerIndicator> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.isActive ? ViernesColors.success : ViernesColors.danger;
    final backgroundColor = widget.isActive
        ? ViernesColors.successLight
        : ViernesColors.dangerLight;
    final label = widget.isActive ? 'Activo' : 'Inactivo';
    final description = widget.isActive
        ? 'Disponible para atender clientes'
        : 'No disponible para nuevos clientes';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : backgroundColor.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
                widget.onTap?.call();
              },
              child: Row(
                children: [
                  _PulsingDot(color: color, isActive: widget.isActive),
                  const SizedBox(width: ViernesSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isDark ? Colors.white : ViernesColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: isDark ? Colors.white : ViernesColors.primary,
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(
                  top: ViernesSpacing.xs,
                  left: ViernesSpacing.lg + ViernesSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    description,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : ViernesColors.primary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// VARIANT 4: FLOATING PILL - Floating badge with animation
// ============================================================================
class _FloatingPillIndicator extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onTap;

  const _FloatingPillIndicator({
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isActive ? ViernesColors.success : ViernesColors.danger;
    final label = isActive ? 'Activo' : 'Inactivo';

    return Padding(
      padding: const EdgeInsets.all(ViernesSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.md,
            vertical: ViernesSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? ViernesColors.panelDark
                : ViernesColors.panelLight,
            borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingDot(color: color, isActive: isActive),
              const SizedBox(width: ViernesSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : ViernesColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SHARED COMPONENT: Pulsing Dot Animation
// ============================================================================
class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool isActive;

  const _PulsingDot({
    required this.color,
    required this.isActive,
  });

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _animation.value * 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
