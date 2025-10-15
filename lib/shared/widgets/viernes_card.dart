import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_spacing.dart';

/// Modern Viernes card component following 2025 design trends
///
/// Features:
/// - Multiple card types (basic, elevated, outlined, glass)
/// - Gradient support
/// - Hover states
/// - Loading shimmer effect
/// - Action buttons support
/// - Responsive design
enum ViernesCardType {
  basic,
  elevated,
  outlined,
  glass,
}

class ViernesCard extends ConsumerWidget {
  final Widget child;
  final ViernesCardType type;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final bool hasGradient;
  final Gradient? customGradient;
  final List<BoxShadow>? customShadows;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool isLoading;

  const ViernesCard({
    super.key,
    required this.child,
    this.type = ViernesCardType.basic,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.hasGradient = false,
    this.customGradient,
    this.customShadows,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = ViernesSpacing.radiusLg,
    this.isLoading = false,
  });

  const ViernesCard.basic({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.isLoading = false,
  }) : type = ViernesCardType.basic,
       hasGradient = false,
       customGradient = null,
       customShadows = null,
       borderColor = null,
       borderWidth = 1.0,
       borderRadius = ViernesSpacing.radiusLg;

  const ViernesCard.elevated({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.customShadows,
    this.isLoading = false,
  }) : type = ViernesCardType.elevated,
       hasGradient = false,
       customGradient = null,
       borderColor = null,
       borderWidth = 1.0,
       borderRadius = ViernesSpacing.radiusLg;

  const ViernesCard.outlined({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.isLoading = false,
  }) : type = ViernesCardType.outlined,
       hasGradient = false,
       customGradient = null,
       customShadows = null,
       borderRadius = ViernesSpacing.radiusLg;

  const ViernesCard.glass({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isLoading = false,
  }) : type = ViernesCardType.glass,
       hasGradient = false,
       customGradient = null,
       customShadows = null,
       backgroundColor = null,
       borderColor = null,
       borderWidth = 1.0,
       borderRadius = ViernesSpacing.radiusLg;

  const ViernesCard.filled({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.isLoading = false,
  }) : type = ViernesCardType.basic,
       hasGradient = false,
       customGradient = null,
       customShadows = null,
       borderColor = null,
       borderWidth = 1.0,
       borderRadius = ViernesSpacing.radiusLg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    if (isLoading) {
      return _buildLoadingCard(isDark);
    }

    final colors = _getCardColors(isDark);
    final shadows = _getCardShadows(isDark);

    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(ViernesSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: _buildCardDecoration(colors, shadows, isDark),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding ?? const EdgeInsets.all(ViernesSpacing.md),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Container(
      width: width,
      height: height ?? 120,
      margin: margin ?? const EdgeInsets.all(ViernesSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? ViernesColors.panelDark : ViernesColors.panelLight,
        borderRadius: BorderRadius.circular(borderRadius),
        border: type == ViernesCardType.outlined
            ? Border.all(
                color: isDark
                    ? ViernesColors.getBorderColor(true)
                    : ViernesColors.getBorderColor(false),
                width: borderWidth,
              )
            : null,
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(CardColors colors, List<BoxShadow> shadows, bool isDark) {
    switch (type) {
      case ViernesCardType.basic:
        return BoxDecoration(
          color: hasGradient ? null : colors.backgroundColor,
          gradient: hasGradient ? (customGradient ?? _getDefaultGradient(isDark)) : null,
          borderRadius: BorderRadius.circular(borderRadius),
        );

      case ViernesCardType.elevated:
        return BoxDecoration(
          color: hasGradient ? null : colors.backgroundColor,
          gradient: hasGradient ? (customGradient ?? _getDefaultGradient(isDark)) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: customShadows ?? shadows,
        );

      case ViernesCardType.outlined:
        return BoxDecoration(
          color: hasGradient ? null : colors.backgroundColor,
          gradient: hasGradient ? (customGradient ?? _getDefaultGradient(isDark)) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? colors.borderColor,
            width: borderWidth,
          ),
        );

      case ViernesCardType.glass:
        return BoxDecoration(
          color: isDark
              ? ViernesColors.panelDark.withValues(alpha: 0.7)
              : ViernesColors.panelLight.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );
    }
  }

  Gradient _getDefaultGradient(bool isDark) {
    return LinearGradient(
      colors: isDark
          ? [
              ViernesColors.panelDark,
              ViernesColors.primary.withValues(alpha: 0.1),
            ]
          : [
              ViernesColors.panelLight,
              ViernesColors.secondary.withValues(alpha: 0.1),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  CardColors _getCardColors(bool isDark) {
    return CardColors(
      backgroundColor: backgroundColor ?? (isDark ? ViernesColors.panelDark : ViernesColors.panelLight),
      borderColor: isDark ? ViernesColors.getBorderColor(true) : ViernesColors.getBorderColor(false),
    );
  }

  List<BoxShadow> _getCardShadows(bool isDark) {
    switch (type) {
      case ViernesCardType.elevated:
        return [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : ViernesColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : ViernesColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ];
      default:
        return [];
    }
  }
}

class CardColors {
  final Color backgroundColor;
  final Color borderColor;

  const CardColors({
    required this.backgroundColor,
    required this.borderColor,
  });
}

/// Specialized card for metrics/statistics
class ViernesMetricCard extends ConsumerWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const ViernesMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return ViernesCard.elevated(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(ViernesSpacing.xs),
                  decoration: BoxDecoration(
                    color: (iconColor ?? ViernesColors.accent).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(ViernesSpacing.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? ViernesColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: ViernesSpacing.sm),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? ViernesColors.getTextColor(true).withValues(alpha: 0.7)
                        : ViernesColors.getTextColor(false).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: ViernesSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? ViernesColors.getTextColor(true) : ViernesColors.getTextColor(false),
            ),
          ),
          if (subtitle != null || trend != null) ...[
            const SizedBox(height: ViernesSpacing.xs),
            Row(
              children: [
                if (subtitle != null) ...[
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? ViernesColors.getTextColor(true).withValues(alpha: 0.6)
                            : ViernesColors.getTextColor(false).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
                if (trend != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ViernesSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPositiveTrend
                          ? ViernesColors.success.withValues(alpha: 0.1)
                          : ViernesColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ViernesSpacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                          size: 12,
                          color: isPositiveTrend ? ViernesColors.success : ViernesColors.danger,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trend!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isPositiveTrend ? ViernesColors.success : ViernesColors.danger,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Card for chat conversations
class ViernesConversationCard extends ConsumerWidget {
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  final bool isOnline;
  final int unreadCount;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const ViernesConversationCard({
    super.key,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    this.isOnline = false,
    this.unreadCount = 0,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return ViernesCard.basic(
      onTap: onTap,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ViernesColors.primary.withValues(alpha: 0.1),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                        title.isNotEmpty ? title[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: isDark ? ViernesColors.secondary : ViernesColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: ViernesColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? ViernesColors.panelDark : ViernesColors.panelLight,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: ViernesSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                          color: isDark ? ViernesColors.getTextColor(true) : ViernesColors.getTextColor(false),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTimestamp(timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? ViernesColors.getTextColor(true).withValues(alpha: 0.6)
                            : ViernesColors.getTextColor(false).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lastMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? ViernesColors.getTextColor(true).withValues(alpha: 0.7)
                              : ViernesColors.getTextColor(false).withValues(alpha: 0.7),
                          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unreadCount > 0)
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ViernesColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}