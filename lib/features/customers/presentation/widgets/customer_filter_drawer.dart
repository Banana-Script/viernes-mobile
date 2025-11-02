import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../../domain/entities/customer_filters.dart';
import '../providers/customer_provider.dart';

/// Customer Filter Drawer Widget
///
/// A side drawer for filtering customers with multiple filter options:
/// - Owner/Agent (multi-select with "Viernes" option for unassigned)
/// - Segment (multi-select)
/// - Date Created (date range)
/// - Last Interaction (date range)
///
/// Design follows Viernes glassmorphism aesthetic with smooth animations.
class CustomerFilterDrawer extends StatefulWidget {
  const CustomerFilterDrawer({super.key});

  @override
  State<CustomerFilterDrawer> createState() => _CustomerFilterDrawerState();
}

class _CustomerFilterDrawerState extends State<CustomerFilterDrawer> {
  late List<int> _selectedOwnerIds;
  late List<String> _selectedSegments;
  late DateTimeRange? _dateCreatedRange;
  late DateTimeRange? _lastInteractionRange;

  @override
  void initState() {
    super.initState();
    // Initialize from current provider filters
    final provider = context.read<CustomerProvider>();
    _selectedOwnerIds = List.from(provider.filters.ownerIds ?? []);
    _selectedSegments = List.from(provider.filters.segments ?? []);
    _dateCreatedRange = _dateRangeToDateTimeRange(provider.filters.createdDateRange);
    _lastInteractionRange = _dateRangeToDateTimeRange(provider.filters.lastInteractionRange);
  }

  DateTimeRange? _dateRangeToDateTimeRange(DateRange? dateRange) {
    if (dateRange == null || (dateRange.startDate == null && dateRange.endDate == null)) {
      return null;
    }
    return DateTimeRange(
      start: dateRange.startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      end: dateRange.endDate ?? DateTime.now(),
    );
  }

  DateRange? _dateTimeRangeToDateRange(DateTimeRange? dateTimeRange) {
    if (dateTimeRange == null) return null;
    return DateRange(
      startDate: dateTimeRange.start,
      endDate: dateTimeRange.end,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedOwnerIds.clear();
      _selectedSegments.clear();
      _dateCreatedRange = null;
      _lastInteractionRange = null;
    });
  }

  void _applyFilters() {
    final provider = context.read<CustomerProvider>();

    final filters = CustomerFilters(
      ownerIds: _selectedOwnerIds.isNotEmpty ? _selectedOwnerIds : null,
      segments: _selectedSegments.isNotEmpty ? _selectedSegments : null,
      createdDateRange: _dateTimeRangeToDateRange(_dateCreatedRange),
      lastInteractionRange: _dateTimeRangeToDateRange(_lastInteractionRange),
    );

    provider.applyFilters(filters);
    Navigator.of(context).pop();
  }

  Future<void> _selectDateRange(BuildContext context, bool isCreatedDate) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialRange = isCreatedDate ? _dateCreatedRange : _lastInteractionRange;

    final DateTimeRange? picked = await showRangePickerDialog(
      context: context,
      minDate: DateTime(2020),
      maxDate: DateTime.now(),
      selectedRange: initialRange,
      // Styling parameters
      slidersColor: isDark ? ViernesColors.accent : ViernesColors.primary,
      highlightColor: isDark ? ViernesColors.accent : ViernesColors.primary,
      slidersSize: 20,
      splashColor: (isDark ? ViernesColors.accent : ViernesColors.primary).withValues(alpha: 0.1),
      splashRadius: 40,
      centerLeadingDate: true,
      // Selected range cells styling
      selectedCellsDecoration: BoxDecoration(
        color: isDark ? ViernesColors.accent : ViernesColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      selectedCellsTextStyle: TextStyle(
        color: isDark ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      // Current date styling
      currentDateDecoration: BoxDecoration(
        border: Border.all(
          color: isDark ? ViernesColors.accent : ViernesColors.primary,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      currentDateTextStyle: TextStyle(
        color: isDark ? ViernesColors.accent : ViernesColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      // Disabled cells styling
      disabledCellsTextStyle: TextStyle(
        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
        fontSize: 14,
      ),
      // Enabled cells styling
      enabledCellsTextStyle: TextStyle(
        color: ViernesColors.getTextColor(isDark),
        fontSize: 14,
      ),
      // Days of week styling
      daysOfTheWeekTextStyle: TextStyle(
        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      // Leading date (header) styling
      leadingDateTextStyle: TextStyle(
        color: ViernesColors.getTextColor(isDark),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isCreatedDate) {
          _dateCreatedRange = picked;
        } else {
          _lastInteractionRange = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: ViernesBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(isDark),

              // Filters content
              Expanded(
                child: Consumer<CustomerProvider>(
                  builder: (context, provider, _) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(ViernesSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Owner/Agent filter
                          _buildFilterSection(
                            title: 'Owner/Agent',
                            isDark: isDark,
                            child: _buildOwnerMultiSelect(provider, isDark),
                          ),

                          const SizedBox(height: ViernesSpacing.lg),

                          // Segment filter
                          _buildFilterSection(
                            title: 'Segment',
                            isDark: isDark,
                            child: _buildSegmentMultiSelect(provider, isDark),
                          ),

                          const SizedBox(height: ViernesSpacing.lg),

                          // Date Created filter
                          _buildFilterSection(
                            title: 'Date Created',
                            isDark: isDark,
                            child: _buildDateRangeButton(
                              label: _dateCreatedRange == null
                                  ? 'Select date range'
                                  : _formatDateRange(_dateCreatedRange!),
                              onTap: () => _selectDateRange(context, true),
                              onClear: _dateCreatedRange != null
                                  ? () => setState(() => _dateCreatedRange = null)
                                  : null,
                              isDark: isDark,
                            ),
                          ),

                          const SizedBox(height: ViernesSpacing.lg),

                          // Last Interaction filter
                          _buildFilterSection(
                            title: 'Last Interaction',
                            isDark: isDark,
                            child: _buildDateRangeButton(
                              label: _lastInteractionRange == null
                                  ? 'Select date range'
                                  : _formatDateRange(_lastInteractionRange!),
                              onTap: () => _selectDateRange(context, false),
                              onClear: _lastInteractionRange != null
                                  ? () => setState(() => _lastInteractionRange = null)
                                  : null,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Action buttons
              _buildActionButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: ViernesColors.getTextColor(isDark),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Filters',
              style: ViernesTextStyles.h4.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required bool isDark,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ViernesTextStyles.h6.copyWith(
            color: ViernesColors.getTextColor(isDark),
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        child,
      ],
    );
  }

  Widget _buildOwnerMultiSelect(CustomerProvider provider, bool isDark) {
    // Convert available owners to list of options
    final owners = provider.availableOwners;

    // Add "Viernes" (unassigned) option at the beginning
    final options = <Map<String, dynamic>>[
      {'id': -1, 'name': 'Viernes (Unassigned)'},
      ...owners,
    ];

    return Wrap(
      spacing: ViernesSpacing.sm,
      runSpacing: ViernesSpacing.sm,
      children: options.map((owner) {
        final id = owner['id'] as int;
        final name = owner['name'] as String;
        final isSelected = _selectedOwnerIds.contains(id);

        return _buildChip(
          label: name,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedOwnerIds.remove(id);
              } else {
                _selectedOwnerIds.add(id);
              }
            });
          },
          isDark: isDark,
        );
      }).toList(),
    );
  }

  Widget _buildSegmentMultiSelect(CustomerProvider provider, bool isDark) {
    final segments = provider.availableSegments;

    if (segments.isEmpty) {
      return Text(
        'No segments available',
        style: ViernesTextStyles.bodySmall.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: ViernesSpacing.sm,
      runSpacing: ViernesSpacing.sm,
      children: segments.map((segment) {
        final isSelected = _selectedSegments.contains(segment);
        return _buildChip(
          label: segment,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSegments.remove(segment);
              } else {
                _selectedSegments.add(segment);
              }
            });
          },
          isDark: isDark,
        );
      }).toList(),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: ViernesSpacing.md,
          vertical: ViernesSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? ViernesColors.accent : ViernesColors.secondary)
                  .withValues(alpha: 0.2)
              : (isDark ? ViernesColors.accent : ViernesColors.primary)
                  .withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusXl),
          border: Border.all(
            color: isSelected
                ? (isDark ? ViernesColors.accent : ViernesColors.secondary)
                : (isDark ? ViernesColors.accent : ViernesColors.primary)
                    .withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 4, top: 2),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: isDark ? ViernesColors.accent : ViernesColors.primary,
                  ),
                ),
              Flexible(
                child: Text(
                  label,
                  style: ViernesTextStyles.bodyText.copyWith(
                    color: ViernesColors.getTextColor(isDark),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeButton({
    required String label,
    required VoidCallback onTap,
    required VoidCallback? onClear,
    required bool isDark,
  }) {
    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius14,
      padding: const EdgeInsets.all(ViernesSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 20,
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
          ),
          const SizedBox(width: ViernesSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              icon: Icon(
                Icons.clear,
                size: 20,
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
              ),
              onPressed: onClear,
              splashRadius: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final hasActiveFilters = _selectedOwnerIds.isNotEmpty ||
        _selectedSegments.isNotEmpty ||
        _dateCreatedRange != null ||
        _lastInteractionRange != null;

    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Clear filters button
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                border: Border.all(
                  color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: hasActiveFilters ? _clearFilters : null,
                  borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
                  child: Center(
                    child: Text(
                      'Clear Filters',
                      style: ViernesTextStyles.buttonMedium.copyWith(
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
            child: ViernesGradientButton(
              text: 'Apply Filters',
              onPressed: _applyFilters,
              isLoading: false,
              height: 48,
              borderRadius: ViernesSpacing.radius14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTimeRange range) {
    final startStr = '${range.start.day}/${range.start.month}/${range.start.year}';
    final endStr = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$startStr - $endStr';
  }
}
