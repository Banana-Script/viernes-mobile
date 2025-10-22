import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_text_styles.dart';
import '../../core/theme/viernes_spacing.dart';

/// Viernes Input Field Component
///
/// Comprehensive input field implementation following Viernes design system:
/// - Consistent styling with theme support
/// - Multiple input types and validation
/// - Password visibility toggle
/// - Custom prefix/suffix icons
/// - Error states and helper text
/// - Accessibility support
class ViernesInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final ViernesInputSize size;
  final ViernesInputVariant variant;
  final Color? fillColor;
  final Color? borderColor;
  final FocusNode? focusNode;

  const ViernesInput({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.size = ViernesInputSize.medium,
    this.variant = ViernesInputVariant.outlined,
    this.fillColor,
    this.borderColor,
    this.focusNode,
  });

  // Named constructors for common input types

  /// Email input with appropriate keyboard and validation
  const ViernesInput.email({
    super.key,
    this.controller,
    this.labelText = 'Email',
    this.hintText = 'Enter your email',
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.size = ViernesInputSize.medium,
    this.variant = ViernesInputVariant.outlined,
    this.fillColor,
    this.borderColor,
    this.focusNode,
  }) : isPassword = false,
       maxLines = 1,
       maxLength = null,
       keyboardType = TextInputType.emailAddress,
       textInputAction = TextInputAction.next,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       prefixText = null,
       suffixText = null;

  /// Password input with visibility toggle
  const ViernesInput.password({
    super.key,
    this.controller,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.size = ViernesInputSize.medium,
    this.variant = ViernesInputVariant.outlined,
    this.fillColor,
    this.borderColor,
    this.focusNode,
  }) : isPassword = true,
       maxLines = 1,
       maxLength = null,
       keyboardType = TextInputType.visiblePassword,
       textInputAction = TextInputAction.done,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       suffixIcon = null,
       prefixText = null,
       suffixText = null;

  /// Search input with search icon
  const ViernesInput.search({
    super.key,
    this.controller,
    this.labelText,
    this.hintText = 'Search...',
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.suffixIcon,
    this.size = ViernesInputSize.medium,
    this.variant = ViernesInputVariant.outlined,
    this.fillColor,
    this.borderColor,
    this.focusNode,
  }) : isPassword = false,
       maxLines = 1,
       maxLength = null,
       keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       prefixIcon = const Icon(Icons.search),
       prefixText = null,
       suffixText = null;

  /// Multiline text area
  const ViernesInput.textArea({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 4,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.size = ViernesInputSize.medium,
    this.variant = ViernesInputVariant.outlined,
    this.fillColor,
    this.borderColor,
    this.focusNode,
  }) : isPassword = false,
       keyboardType = TextInputType.multiline,
       textInputAction = TextInputAction.newline,
       textCapitalization = TextCapitalization.sentences,
       inputFormatters = null,
       prefixText = null,
       suffixText = null;

  @override
  State<ViernesInput> createState() => _ViernesInputState();
}

class _ViernesInputState extends State<ViernesInput> {
  bool _isPasswordVisible = false;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: ViernesTextStyles.label.copyWith(
              color: widget.errorText != null
                  ? ViernesColors.danger
                  : _hasFocus
                      ? (isDark ? ViernesColors.secondary : ViernesColors.primary)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          ViernesSpacing.spaceXs,
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: isDark
                          ? const Color(0x1A51f5f8) // rgba(81, 245, 248, 0.1)
                          : const Color(0x14374151), // rgba(55, 65, 81, 0.08)
                      blurRadius: 0,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onSubmitted,
            obscureText: widget.isPassword && !_isPasswordVisible,
            style: _getTextStyle(isDark),
            decoration: _buildInputDecoration(theme, isDark),
          ),
        ),
        if (widget.helperText != null || widget.errorText != null) ...[
          ViernesSpacing.spaceXs,
          Text(
            widget.errorText ?? widget.helperText!,
            style: ViernesTextStyles.caption.copyWith(
              color: widget.errorText != null
                  ? ViernesColors.danger
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme, bool isDark) {
    final hasError = widget.errorText != null;
    final borderColor = widget.borderColor ??
        (hasError
            ? ViernesColors.danger
            : _hasFocus
                ? (isDark ? ViernesColors.secondary : ViernesColors.primary)
                : (isDark
                    ? ViernesColors.primaryLight.withValues(alpha: 0.3)
                    : ViernesColors.primaryLight));

    final fillColor = widget.fillColor ??
        (isDark ? ViernesColors.panelDark : Colors.white);

    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: ViernesTextStyles.bodyText.copyWith(
        color: isDark
            ? Colors.white.withValues(alpha: 0.5)
            : ViernesColors.primaryLight,
      ),
      filled: widget.variant == ViernesInputVariant.filled,
      fillColor: fillColor,
      prefixIcon: widget.prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 16, right: 0),
              child: widget.prefixIcon,
            )
          : null,
      prefixIconConstraints: widget.prefixIcon != null
          ? const BoxConstraints(minWidth: 36, minHeight: 20)
          : null,
      suffixIcon: _buildSuffixIcon(),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      contentPadding: _getPadding(),
      border: _buildBorder(borderColor),
      enabledBorder: _buildBorder(borderColor),
      focusedBorder: _buildBorder(borderColor, focused: true),
      errorBorder: _buildBorder(ViernesColors.danger),
      focusedErrorBorder: _buildBorder(ViernesColors.danger, focused: true),
      disabledBorder: _buildBorder(
        borderColor.withValues(alpha: 0.5),
      ),
      counterStyle: ViernesTextStyles.caption.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      errorStyle: ViernesTextStyles.caption.copyWith(
        color: ViernesColors.danger,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  InputBorder _buildBorder(Color color, {bool focused = false}) {
    final radius = BorderRadius.circular(_getBorderRadius());

    switch (widget.variant) {
      case ViernesInputVariant.outlined:
        return OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: color,
            width: 2.0, // Always 2px to match Figma design
          ),
        );
      case ViernesInputVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: color,
            width: focused ? 2.0 : 1.0,
          ),
        );
      case ViernesInputVariant.filled:
        return OutlineInputBorder(
          borderRadius: radius,
          borderSide: focused
              ? BorderSide(color: color, width: 2.0)
              : BorderSide.none,
        );
    }
  }

  EdgeInsets _getPadding() {
    // Match Figma design: space for prefix icon on left, standard padding elsewhere
    if (widget.prefixIcon != null) {
      return const EdgeInsets.only(
        left: ViernesSpacing.inputPrefixIconSpace,
        right: ViernesSpacing.md,
        top: ViernesSpacing.md,
        bottom: ViernesSpacing.md,
      );
    }
    return const EdgeInsets.all(ViernesSpacing.md);
  }

  double _getBorderRadius() {
    // Always use 14px radius to match Figma design
    return ViernesSpacing.radius14;
  }

  TextStyle _getTextStyle(bool isDark) {
    final baseStyle = widget.size == ViernesInputSize.large
        ? ViernesTextStyles.bodyLarge
        : widget.size == ViernesInputSize.small
            ? ViernesTextStyles.bodySmall
            : ViernesTextStyles.bodyText;

    return baseStyle.copyWith(
      color: isDark ? Colors.white : ViernesColors.primary,
    );
  }
}

// Input size enumeration
enum ViernesInputSize {
  small,
  medium,
  large,
}

// Input variant enumeration
enum ViernesInputVariant {
  outlined,
  filled,
  underlined,
}