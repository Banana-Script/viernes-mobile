import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../providers/customer_provider.dart';

/// Customer Search Bar Widget
///
/// A search bar with debounce functionality and glassmorphism styling.
/// Features:
/// - Real-time search with debounce (500ms)
/// - Clear button when text is entered
/// - Smooth animations
/// - Consistent with Viernes design system
class CustomerSearchBar extends StatefulWidget {
  final String hintText;
  final int debounceDuration;

  const CustomerSearchBar({
    super.key,
    this.hintText = 'Search customers...',
    this.debounceDuration = 500,
  });

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = context.read<CustomerProvider>();

    // Update search term immediately (for UI state)
    provider.updateSearchTerm(_controller.text);

    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start new timer for actual search
    _debounce = Timer(Duration(milliseconds: widget.debounceDuration), () {
      provider.applySearch();
    });

    // Trigger rebuild for clear button visibility
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    final provider = context.read<CustomerProvider>();
    provider.updateSearchTerm('');
    provider.applySearch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
        controller: _controller,
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: ViernesTextStyles.bodyText.copyWith(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
            size: 20,
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.md,
            vertical: ViernesSpacing.space3,
          ),
        ),
      ),
    );
  }
}
