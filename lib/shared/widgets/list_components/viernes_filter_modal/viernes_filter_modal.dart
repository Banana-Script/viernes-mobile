import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../viernes_gradient_button.dart';

/// Viernes Filter Modal
///
/// A bottom sheet modal for filtering list items with customizable sections.
///
/// Features:
/// - DraggableScrollableSheet with header and footer
/// - Customizable filter sections via children
/// - Apply and Clear buttons
/// - Theme-aware colors (light/dark mode)
class ViernesFilterModal extends StatelessWidget {
  /// Modal title
  final String title;

  /// Filter section widgets
  final List<Widget> children;

  /// Callback when Apply button is pressed
  final VoidCallback onApply;

  /// Callback when Clear button is pressed
  final VoidCallback onClear;

  /// Whether any filters are currently active
  final bool hasActiveFilters;

  /// Initial size of the draggable sheet (0.0 to 1.0)
  final double initialChildSize;

  /// Minimum size of the draggable sheet
  final double minChildSize;

  /// Maximum size of the draggable sheet
  final double maxChildSize;

  /// Apply button label
  final String applyLabel;

  /// Clear button label
  final String clearLabel;

  const ViernesFilterModal({
    super.key,
    this.title = 'Filters',
    required this.children,
    required this.onApply,
    required this.onClear,
    this.hasActiveFilters = false,
    this.initialChildSize = 0.9,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.9,
    this.applyLabel = 'Apply Filters',
    this.clearLabel = 'Clear Filters',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: ViernesColors.getControlBackground(isDark),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: ViernesSpacing.md,
                  vertical: ViernesSpacing.sm,
                ),
                children: [
                  ...children.expand((child) => [
                    child,
                    const SizedBox(height: ViernesSpacing.md),
                  ]),
                  const SizedBox(height: ViernesSpacing.xl),
                ],
              ),
            ),
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: ViernesTextStyles.h6.copyWith(
              color: ViernesColors.getTextColor(isDark),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.close,
              color: ViernesColors.getTextColor(isDark),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        border: Border(
          top: BorderSide(
            color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Clear filters button
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                  border: Border.all(
                    color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: hasActiveFilters ? onClear : null,
                    borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                    child: Center(
                      child: Text(
                        clearLabel,
                        style: ViernesTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasActiveFilters
                              ? ViernesColors.getTextColor(isDark)
                              : ViernesColors.getTextColor(isDark)
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: ViernesSpacing.sm),
            // Apply filters button
            Expanded(
              flex: 2,
              child: ViernesGradientButton(
                text: applyLabel,
                onPressed: onApply,
                height: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Viernes Filter Section
///
/// A labeled section container for filter options.
class ViernesFilterSection extends StatelessWidget {
  /// Section title
  final String title;

  /// Content widget (chips, checkboxes, date pickers, etc.)
  final Widget child;

  const ViernesFilterSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ViernesTextStyles.h6.copyWith(
            color: ViernesColors.getTextColor(isDark),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        child,
      ],
    );
  }
}

/// Viernes Filter Chip Group
///
/// A group of filter chips with selection management.
class ViernesFilterChipGroup<T> extends StatelessWidget {
  /// Available options
  final List<T> options;

  /// Currently selected options
  final List<T> selected;

  /// Builds the label string from an option
  final String Function(T) labelBuilder;

  /// Called when an option is toggled
  final ValueChanged<T> onToggle;

  /// Optional color builder for custom chip colors
  final Color Function(T)? colorBuilder;

  /// Optional leading widget builder for chips
  final Widget Function(T)? leadingBuilder;

  const ViernesFilterChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onToggle,
    this.colorBuilder,
    this.leadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: ViernesSpacing.sm,
      runSpacing: ViernesSpacing.sm,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        final selectedColor = colorBuilder?.call(option) ??
            (isDark ? ViernesColors.accent : ViernesColors.secondary);

        return FilterChip(
          label: leadingBuilder != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    leadingBuilder!(option),
                    const SizedBox(width: 6),
                    Text(labelBuilder(option)),
                  ],
                )
              : Text(labelBuilder(option)),
          selected: isSelected,
          onSelected: (_) => onToggle(option),
          selectedColor: selectedColor.withValues(alpha: 0.2),
          checkmarkColor: colorBuilder != null
              ? selectedColor
              : (isDark ? ViernesColors.accent : Colors.black),
          backgroundColor: ViernesColors.getControlBackground(isDark),
          side: BorderSide(
            color: isSelected
                ? selectedColor
                : ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
          ),
        );
      }).toList(),
    );
  }
}

/// Viernes Date Range Field
///
/// A date picker field for filter date ranges.
class ViernesDateRangeField extends StatelessWidget {
  /// Field label
  final String label;

  /// Currently selected date
  final DateTime? value;

  /// Called when field is tapped
  final VoidCallback onTap;

  const ViernesDateRangeField({
    super.key,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
          ),
        ),
        child: Text(
          value != null
              ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
              : 'Select date',
          style: ViernesTextStyles.bodyText.copyWith(
            color: value != null
                ? ViernesColors.getTextColor(isDark)
                : ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
