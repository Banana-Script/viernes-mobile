import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_spacing.dart';

/// Modern Viernes button component following 2025 design trends
///
/// Features:
/// - Multiple button types (primary, secondary, accent, outline, text)
/// - Loading states with animations
/// - Proper accessibility
/// - Touch-friendly design (minimum 44px height)
/// - Gradient support
/// - Icon support
enum ViernesButtonType {
  primary,
  secondary,
  accent,
  outline,
  text,
  danger,
  success,
}

enum ViernesButtonSize {
  small,   // 32px height
  medium,  // 44px height (default)
  large,   // 52px height
}

class ViernesButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final ViernesButtonType type;
  final ViernesButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool hasGradient;
  final Widget? customChild;

  const ViernesButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ViernesButtonType.primary,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.hasGradient = false,
    this.customChild,
  });

  const ViernesButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.hasGradient = false,
    this.customChild,
  }) : type = ViernesButtonType.primary;

  const ViernesButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.hasGradient = false,
    this.customChild,
  }) : type = ViernesButtonType.secondary;

  const ViernesButton.accent({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.hasGradient = false,
    this.customChild,
  }) : type = ViernesButtonType.accent;

  const ViernesButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customChild,
  }) : type = ViernesButtonType.outline, hasGradient = false;

  const ViernesButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customChild,
  }) : type = ViernesButtonType.text, hasGradient = false;

  const ViernesButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customChild,
  }) : type = ViernesButtonType.danger, hasGradient = false;

  const ViernesButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customChild,
  }) : type = ViernesButtonType.success, hasGradient = false;

  const ViernesButton.gradient({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customChild,
  }) : type = ViernesButtonType.primary, hasGradient = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDark, isEnabled),
    );
  }

  double _getHeight() {
    switch (size) {
      case ViernesButtonSize.small:
        return 32.0;
      case ViernesButtonSize.medium:
        return 44.0;
      case ViernesButtonSize.large:
        return 52.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ViernesButtonSize.small:
        return 14.0;
      case ViernesButtonSize.medium:
        return 16.0;
      case ViernesButtonSize.large:
        return 18.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ViernesButtonSize.small:
        return 16.0;
      case ViernesButtonSize.medium:
        return 18.0;
      case ViernesButtonSize.large:
        return 20.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ViernesButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: ViernesSpacing.sm);
      case ViernesButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: ViernesSpacing.md);
      case ViernesButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: ViernesSpacing.lg);
    }
  }

  Widget _buildButton(BuildContext context, bool isDark, bool isEnabled) {
    final colors = _getButtonColors(isDark);

    if (type == ViernesButtonType.text) {
      return _buildTextButton(colors, isEnabled);
    }

    return Container(
      decoration: hasGradient && isEnabled
          ? BoxDecoration(
              gradient: _getGradient(isDark),
              borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: colors.shadowColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Material(
        color: hasGradient ? Colors.transparent : colors.backgroundColor,
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        elevation: _getElevation(),
        shadowColor: colors.shadowColor,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
          child: Container(
            padding: _getPadding(),
            decoration: type == ViernesButtonType.outline
                ? BoxDecoration(
                    border: Border.all(
                      color: isEnabled ? colors.borderColor : colors.borderColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                  )
                : null,
            child: _buildButtonContent(colors, isEnabled),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton(ButtonColors colors, bool isEnabled) {
    return TextButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: _buildButtonIcon(colors, isEnabled),
      label: _buildButtonText(colors, isEnabled),
      style: TextButton.styleFrom(
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        ),
      ),
    );
  }

  Widget _buildButtonContent(ButtonColors colors, bool isEnabled) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.foregroundColor),
          ),
        ),
      );
    }

    if (customChild != null) {
      return Center(child: customChild!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          _buildButtonIcon(colors, isEnabled),
          const SizedBox(width: ViernesSpacing.xs),
        ],
        _buildButtonText(colors, isEnabled),
      ],
    );
  }

  Widget _buildButtonIcon(ButtonColors colors, bool isEnabled) {
    if (icon == null) return const SizedBox.shrink();

    return Icon(
      icon,
      size: _getIconSize(),
      color: isEnabled ? colors.foregroundColor : colors.foregroundColor.withValues(alpha: 0.5),
    );
  }

  Widget _buildButtonText(ButtonColors colors, bool isEnabled) {
    return Text(
      text,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
        color: isEnabled ? colors.foregroundColor : colors.foregroundColor.withValues(alpha: 0.5),
      ),
    );
  }

  double _getElevation() {
    switch (type) {
      case ViernesButtonType.primary:
      case ViernesButtonType.secondary:
      case ViernesButtonType.accent:
      case ViernesButtonType.danger:
      case ViernesButtonType.success:
        return 2.0;
      case ViernesButtonType.outline:
      case ViernesButtonType.text:
        return 0.0;
    }
  }

  Gradient? _getGradient(bool isDark) {
    if (!hasGradient) return null;

    switch (type) {
      case ViernesButtonType.primary:
        return LinearGradient(
          colors: isDark
              ? [ViernesColors.secondary, ViernesColors.secondaryLight]
              : [ViernesColors.primary, ViernesColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ViernesButtonType.accent:
        return LinearGradient(
          colors: [ViernesColors.accent, ViernesColors.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return null;
    }
  }

  ButtonColors _getButtonColors(bool isDark) {
    switch (type) {
      case ViernesButtonType.primary:
        return ButtonColors(
          backgroundColor: isDark ? ViernesColors.secondary : ViernesColors.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          borderColor: isDark ? ViernesColors.secondary : ViernesColors.primary,
          shadowColor: isDark ? ViernesColors.secondary : ViernesColors.primary,
        );

      case ViernesButtonType.secondary:
        return ButtonColors(
          backgroundColor: isDark ? ViernesColors.primary : ViernesColors.secondary,
          foregroundColor: isDark ? Colors.white : Colors.black,
          borderColor: isDark ? ViernesColors.primary : ViernesColors.secondary,
          shadowColor: isDark ? ViernesColors.primary : ViernesColors.secondary,
        );

      case ViernesButtonType.accent:
        return ButtonColors(
          backgroundColor: ViernesColors.accent,
          foregroundColor: Colors.black,
          borderColor: ViernesColors.accent,
          shadowColor: ViernesColors.accent,
        );

      case ViernesButtonType.outline:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? ViernesColors.secondary : ViernesColors.primary,
          borderColor: isDark ? ViernesColors.secondary : ViernesColors.primary,
          shadowColor: Colors.transparent,
        );

      case ViernesButtonType.text:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? ViernesColors.secondary : ViernesColors.primary,
          borderColor: Colors.transparent,
          shadowColor: Colors.transparent,
        );

      case ViernesButtonType.danger:
        return ButtonColors(
          backgroundColor: ViernesColors.danger,
          foregroundColor: Colors.white,
          borderColor: ViernesColors.danger,
          shadowColor: ViernesColors.danger,
        );

      case ViernesButtonType.success:
        return ButtonColors(
          backgroundColor: ViernesColors.success,
          foregroundColor: Colors.white,
          borderColor: ViernesColors.success,
          shadowColor: ViernesColors.success,
        );
    }
  }
}

class ButtonColors {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color shadowColor;

  const ButtonColors({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadowColor,
  });
}