import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';

/// Conversation Search Bar Widget
///
/// A glassmorphism-styled search bar matching the customers page design.
class ConversationSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onClear;
  final Duration debounceDuration;

  const ConversationSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search conversations...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ConversationSearchBar> createState() => _ConversationSearchBarState();
}

class _ConversationSearchBarState extends State<ConversationSearchBar> {
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (widget.onChanged != null) {
        widget.onChanged!(widget.controller.text);
      }
    });
    setState(() {}); // Rebuild to show/hide clear button
  }

  void _clearSearch() {
    widget.controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.md,
        vertical: ViernesSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
              : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: ViernesTextStyles.bodyText.copyWith(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.md,
            vertical: ViernesSpacing.md,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color:
                        ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                  ),
                  onPressed: _clearSearch,
                  splashRadius: 20,
                )
              : null,
        ),
        onSubmitted: (_) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!();
          }
        },
      ),
    );
  }
}
