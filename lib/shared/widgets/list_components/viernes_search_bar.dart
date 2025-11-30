import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';

/// Viernes Search Bar Widget
///
/// A search bar with debounce functionality and glassmorphism styling.
///
/// Features:
/// - Real-time search with configurable debounce
/// - Clear button when text is entered
/// - External controller support
/// - Theme-aware colors (light/dark mode)
/// - Smooth animations
class ViernesSearchBar extends StatefulWidget {
  /// External text controller (optional)
  final TextEditingController? controller;

  /// Placeholder text
  final String hintText;

  /// Debounce duration for search callback
  final Duration debounceDuration;

  /// Callback when search text changes (after debounce)
  final ValueChanged<String>? onSearchChanged;

  /// Callback when clear button is pressed
  final VoidCallback? onClear;

  /// Height of the search bar
  final double height;

  /// Margin around the search bar
  final EdgeInsets? margin;

  const ViernesSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.debounceDuration = const Duration(milliseconds: 500),
    this.onSearchChanged,
    this.onClear,
    this.height = 56,
    this.margin,
  });

  @override
  State<ViernesSearchBar> createState() => _ViernesSearchBarState();
}

class _ViernesSearchBarState extends State<ViernesSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool _ownsController = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onSearchChanged);

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void didUpdateWidget(ViernesSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onSearchChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller != null) {
        _controller = widget.controller!;
        _ownsController = false;
      } else {
        _controller = TextEditingController();
        _ownsController = true;
      }
      _controller.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start new timer for debounced callback
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearchChanged?.call(_controller.text);
    });

    // Trigger rebuild for clear button visibility
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    widget.onSearchChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? ViernesColors.accent : ViernesColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: widget.margin,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
        // Animated border color on focus
        border: Border.all(
          color: _isFocused
              ? accentColor.withValues(alpha: 0.6)
              : isDark
                  ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                  : const Color(0xFFe5e7eb).withValues(alpha: 0.3),
          width: _isFocused ? 1.5 : 1,
        ),
        // Animated shadow on focus
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? accentColor.withValues(alpha: 0.2)
                : isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.12),
            blurRadius: _isFocused ? 16 : 32,
            offset: const Offset(0, 4),
            spreadRadius: _isFocused ? 2 : 0,
          ),
        ],
      ),
      // ClipRRect ensures TextField doesn't overflow borders
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
        child: Center(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: ViernesTextStyles.bodyText.copyWith(
              color: ViernesColors.getTextColor(isDark),
            ),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.search,
                  color: _isFocused
                      ? accentColor
                      : accentColor.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 42,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: ViernesColors.getTextColor(isDark)
                            .withValues(alpha: 0.6),
                        size: 20,
                      ),
                      onPressed: _clearSearch,
                      splashRadius: 20,
                    )
                  : null,
              // Remove ALL TextField borders to eliminate line artifact
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
