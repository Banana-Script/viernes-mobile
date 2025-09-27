import 'package:flutter/material.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_text_styles.dart';
import '../../core/theme/viernes_spacing.dart';

/// Viernes Button Component
///
/// Comprehensive button implementation following Viernes design system:
/// - Primary buttons with brand colors
/// - Secondary/outlined variants
/// - Special Viernes gradient button
/// - Multiple sizes and states
/// - Accessibility support
class ViernesButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ViernesButtonType type;
  final ViernesButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Widget? suffix;
  final Color? customColor;
  final Color? customTextColor;

  const ViernesButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ViernesButtonType.primary,
    this.size = ViernesButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffix,
    this.customColor,
    this.customTextColor,
  });

  // Named constructors for common button types

  /// Primary button with Viernes brand colors
  const ViernesButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffix,
  }) : type = ViernesButtonType.primary,
       customColor = null,
       customTextColor = null;

  /// Secondary/outlined button
  const ViernesButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffix,
  }) : type = ViernesButtonType.secondary,
       customColor = null,
       customTextColor = null;

  /// Text button (no background)
  const ViernesButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffix,
  }) : type = ViernesButtonType.text,
       customColor = null,
       customTextColor = null;

  /// Special Viernes gradient button
  const ViernesButton.gradient({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffix,
  }) : type = ViernesButtonType.gradient,
       customColor = null,
       customTextColor = null;

  /// Danger button for destructive actions
  const ViernesButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffix,
  }) : type = ViernesButtonType.danger,
       customColor = null,
       customTextColor = null;

  /// Success button for positive actions
  const ViernesButton.success({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ViernesButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.suffix,
  }) : type = ViernesButtonType.success,
       customColor = null,
       customTextColor = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get button configuration based on type
    final config = _getButtonConfig(isDark);

    // Build button content
    Widget buttonChild = _buildButtonContent();

    // Apply loading state
    if (isLoading) {
      buttonChild = _buildLoadingContent(config.textColor);
    }

    // Handle gradient button specially
    if (type == ViernesButtonType.gradient) {
      return _buildGradientButton(buttonChild);
    }

    // Build standard button
    return _buildStandardButton(context, config, buttonChild);
  }

  Widget _buildStandardButton(BuildContext context, _ButtonConfig config, Widget child) {
    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return config.backgroundColor?.withValues(alpha: 0.5);
        }
        return config.backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.all(config.textColor),
      overlayColor: WidgetStateProperty.all(config.overlayColor),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) return 0;
        if (states.contains(WidgetState.disabled)) return 0;
        return config.elevation;
      }),
      shadowColor: WidgetStateProperty.all(config.shadowColor),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          side: config.borderSide ?? BorderSide.none,
        ),
      ),
      padding: WidgetStateProperty.all(_getPadding()),
      minimumSize: WidgetStateProperty.all(_getMinimumSize()),
      textStyle: WidgetStateProperty.all(_getTextStyle()),
      animationDuration: const Duration(milliseconds: 200),
    );

    return type == ViernesButtonType.text
        ? TextButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          )
        : type == ViernesButtonType.secondary
            ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: child,
              )
            : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: buttonStyle,
                child: child,
              );
  }

  Widget _buildGradientButton(Widget child) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: _getButtonHeight(),
      decoration: BoxDecoration(
        gradient: ViernesColors.viernesGradient,
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: isLoading || onPressed == null
            ? null
            : ViernesSpacing.primaryShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: Container(
            padding: _getPadding(),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final List<Widget> children = [];

    if (icon != null) {
      children.add(icon!);
      if (text.isNotEmpty) children.add(ViernesSpacing.hSpaceSm);
    }

    if (text.isNotEmpty) {
      children.add(
        Text(
          text,
          style: _getTextStyle(),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (suffix != null) {
      if (text.isNotEmpty || icon != null) children.add(ViernesSpacing.hSpaceSm);
      children.add(suffix!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildLoadingContent(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _getLoadingIndicatorSize(),
          height: _getLoadingIndicatorSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
        if (text.isNotEmpty) ...[
          ViernesSpacing.hSpaceSm,
          Text(
            'Loading...',
            style: _getTextStyle().copyWith(color: textColor),
          ),
        ],
      ],
    );
  }

  _ButtonConfig _getButtonConfig(bool isDark) {
    switch (type) {
      case ViernesButtonType.primary:
        return _ButtonConfig(
          backgroundColor: customColor ?? (isDark ? ViernesColors.secondary : ViernesColors.primary),
          textColor: customTextColor ?? (isDark ? Colors.black : Colors.white),
          overlayColor: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.1),
          elevation: 2,
          shadowColor: (isDark ? ViernesColors.secondary : ViernesColors.primary).withValues(alpha: 0.3),
        );

      case ViernesButtonType.secondary:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          textColor: customTextColor ?? (isDark ? ViernesColors.secondary : ViernesColors.primary),
          overlayColor: (isDark ? ViernesColors.secondary : ViernesColors.primary).withValues(alpha: 0.1),
          elevation: 0,
          borderSide: BorderSide(
            color: customColor ?? (isDark ? ViernesColors.secondary : ViernesColors.primary),
            width: 1.5,
          ),
        );

      case ViernesButtonType.text:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          textColor: customTextColor ?? (isDark ? ViernesColors.secondary : ViernesColors.primary),
          overlayColor: (isDark ? ViernesColors.secondary : ViernesColors.primary).withValues(alpha: 0.1),
          elevation: 0,
        );

      case ViernesButtonType.gradient:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          textColor: customTextColor ?? Colors.white,
          overlayColor: Colors.white.withValues(alpha: 0.1),
          elevation: 4,
        );

      case ViernesButtonType.danger:
        return _ButtonConfig(
          backgroundColor: customColor ?? ViernesColors.danger,
          textColor: customTextColor ?? Colors.white,
          overlayColor: Colors.white.withValues(alpha: 0.1),
          elevation: 2,
          shadowColor: ViernesColors.danger.withValues(alpha: 0.3),
        );

      case ViernesButtonType.success:
        return _ButtonConfig(
          backgroundColor: customColor ?? ViernesColors.success,
          textColor: customTextColor ?? Colors.white,
          overlayColor: Colors.white.withValues(alpha: 0.1),
          elevation: 2,
          shadowColor: ViernesColors.success.withValues(alpha: 0.3),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ViernesButtonSize.small:
        return ViernesSpacing.buttonPaddingSmall;
      case ViernesButtonSize.medium:
        return ViernesSpacing.buttonPaddingMedium;
      case ViernesButtonSize.large:
        return ViernesSpacing.buttonPaddingLarge;
    }
  }

  Size _getMinimumSize() {
    final width = isFullWidth ? double.infinity : 0.0;
    return Size(width, _getButtonHeight());
  }

  double _getButtonHeight() {
    switch (size) {
      case ViernesButtonSize.small:
        return 40;
      case ViernesButtonSize.medium:
        return 48;
      case ViernesButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case ViernesButtonSize.small:
        return ViernesSpacing.radiusSm;
      case ViernesButtonSize.medium:
        return ViernesSpacing.radiusMd;
      case ViernesButtonSize.large:
        return ViernesSpacing.radiusLg;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ViernesButtonSize.small:
        return ViernesTextStyles.buttonSmall;
      case ViernesButtonSize.medium:
        return ViernesTextStyles.buttonMedium;
      case ViernesButtonSize.large:
        return ViernesTextStyles.buttonLarge;
    }
  }

  double _getLoadingIndicatorSize() {
    switch (size) {
      case ViernesButtonSize.small:
        return 16;
      case ViernesButtonSize.medium:
        return 18;
      case ViernesButtonSize.large:
        return 20;
    }
  }
}

// Button configuration helper class
class _ButtonConfig {
  final Color? backgroundColor;
  final Color textColor;
  final Color overlayColor;
  final double elevation;
  final Color? shadowColor;
  final BorderSide? borderSide;

  _ButtonConfig({
    this.backgroundColor,
    required this.textColor,
    required this.overlayColor,
    this.elevation = 0,
    this.shadowColor,
    this.borderSide,
  });
}

// Button type enumeration
enum ViernesButtonType {
  primary,
  secondary,
  text,
  gradient,
  danger,
  success,
}

// Button size enumeration
enum ViernesButtonSize {
  small,
  medium,
  large,
}