import 'package:flutter/material.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_spacing.dart';

/// Viernes Card Component
///
/// Consistent card implementation following Viernes design system:
/// - Multiple card variants (elevated, outlined, filled)
/// - Customizable padding and margins
/// - Theme-aware styling
/// - Optional headers and actions
/// - Accessibility support
class ViernesCard extends StatelessWidget {
  final Widget child;
  final ViernesCardVariant variant;
  final ViernesCardSize size;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final double? borderRadius;
  final VoidCallback? onTap;
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? trailing;
  final bool showDivider;

  const ViernesCard({
    super.key,
    required this.child,
    this.variant = ViernesCardVariant.elevated,
    this.size = ViernesCardSize.medium,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.trailing,
    this.showDivider = false,
  });

  // Named constructors for common card types

  /// Basic elevated card with shadow
  const ViernesCard.elevated({
    super.key,
    required this.child,
    this.size = ViernesCardSize.medium,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.trailing,
    this.showDivider = false,
  }) : variant = ViernesCardVariant.elevated,
       borderColor = null;

  /// Outlined card with border
  const ViernesCard.outlined({
    super.key,
    required this.child,
    this.size = ViernesCardSize.medium,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.trailing,
    this.showDivider = false,
  }) : variant = ViernesCardVariant.outlined,
       elevation = null;

  /// Filled card with background color
  const ViernesCard.filled({
    super.key,
    required this.child,
    this.size = ViernesCardSize.medium,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.trailing,
    this.showDivider = false,
  }) : variant = ViernesCardVariant.filled,
       borderColor = null,
       elevation = null;

  /// Interactive card for tappable content
  const ViernesCard.interactive({
    super.key,
    required this.child,
    required this.onTap,
    this.variant = ViernesCardVariant.elevated,
    this.size = ViernesCardSize.medium,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.trailing,
    this.showDivider = false,
  });

  /// Dashboard card with metrics styling
  const ViernesCard.dashboard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation = 4,
    this.borderRadius,
    this.onTap,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.trailing,
    this.showDivider = false,
  }) : variant = ViernesCardVariant.elevated,
       size = ViernesCardSize.large,
       borderColor = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardConfig = _getCardConfig(isDark);

    Widget cardContent = _buildCardContent();

    // Add header if title or actions are provided
    if (title != null || titleWidget != null || actions != null) {
      cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          if (showDivider) ...[
            ViernesSpacing.spaceSm,
            Divider(
              color: theme.dividerColor,
              height: 1,
            ),
            ViernesSpacing.spaceSm,
          ] else
            ViernesSpacing.spaceMd,
          Flexible(child: cardContent),
        ],
      );
    }

    final card = Container(
      margin: margin ?? _getDefaultMargin(),
      decoration: BoxDecoration(
        color: cardConfig.backgroundColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? _getDefaultBorderRadius(),
        ),
        border: cardConfig.border,
        boxShadow: cardConfig.shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius ?? _getDefaultBorderRadius(),
        ),
        child: Container(
          padding: padding ?? _getDefaultPadding(),
          child: cardContent,
        ),
      ),
    );

    // Wrap in Material for ink effects if interactive
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? _getDefaultBorderRadius(),
          ),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildCardContent() {
    if (leading != null || trailing != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            ViernesSpacing.hSpaceMd,
          ],
          Expanded(child: child),
          if (trailing != null) ...[
            ViernesSpacing.hSpaceMd,
            trailing!,
          ],
        ],
      );
    }
    return child;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: titleWidget ??
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
        ),
        if (actions != null) ...[
          ViernesSpacing.hSpaceMd,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ),
        ],
      ],
    );
  }

  _CardConfig _getCardConfig(bool isDark) {
    final defaultBackgroundColor = backgroundColor ??
        (isDark ? ViernesColors.panelDark : ViernesColors.panelLight);

    switch (variant) {
      case ViernesCardVariant.elevated:
        return _CardConfig(
          backgroundColor: defaultBackgroundColor,
          shadows: elevation != null
              ? [
                  BoxShadow(
                    color: ViernesColors.primary.withValues(alpha: 0.1),
                    blurRadius: elevation! * 2,
                    offset: Offset(0, elevation! / 2),
                  ),
                ]
              : ViernesSpacing.mediumShadow,
        );

      case ViernesCardVariant.outlined:
        return _CardConfig(
          backgroundColor: defaultBackgroundColor,
          border: Border.all(
            color: borderColor ??
                (isDark
                    ? ViernesColors.primaryLight.withValues(alpha: 0.3)
                    : ViernesColors.primaryLight),
            width: 1,
          ),
        );

      case ViernesCardVariant.filled:
        return _CardConfig(
          backgroundColor: backgroundColor ??
              (isDark
                  ? ViernesColors.primary.withValues(alpha: 0.1)
                  : ViernesColors.secondary.withValues(alpha: 0.1)),
        );
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (size) {
      case ViernesCardSize.small:
        return ViernesSpacing.cardPaddingSmall;
      case ViernesCardSize.medium:
        return ViernesSpacing.cardPadding;
      case ViernesCardSize.large:
        return ViernesSpacing.cardPaddingLarge;
    }
  }

  EdgeInsets _getDefaultMargin() {
    return ViernesSpacing.cardMargin;
  }

  double _getDefaultBorderRadius() {
    switch (size) {
      case ViernesCardSize.small:
        return ViernesSpacing.radiusMd;
      case ViernesCardSize.medium:
        return ViernesSpacing.radiusLg;
      case ViernesCardSize.large:
        return ViernesSpacing.radiusXl;
    }
  }
}

// Card configuration helper class
class _CardConfig {
  final Color backgroundColor;
  final Border? border;
  final List<BoxShadow>? shadows;

  _CardConfig({
    required this.backgroundColor,
    this.border,
    this.shadows,
  });
}

// Card variant enumeration
enum ViernesCardVariant {
  elevated,
  outlined,
  filled,
}

// Card size enumeration
enum ViernesCardSize {
  small,
  medium,
  large,
}