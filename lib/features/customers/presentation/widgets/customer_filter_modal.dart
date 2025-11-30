import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../../domain/entities/customer_filters.dart';
import '../providers/customer_provider.dart';

/// Customer Filter Modal
///
/// Bottom sheet modal for filtering customers by owner, segment, and date ranges.
/// Uses DraggableScrollableSheet for consistent UX with ConversationFilterModal.
class CustomerFilterModal extends StatefulWidget {
  final CustomerFilters initialFilters;

  const CustomerFilterModal({
    super.key,
    required this.initialFilters,
  });

  @override
  State<CustomerFilterModal> createState() => _CustomerFilterModalState();
}

class _CustomerFilterModalState extends State<CustomerFilterModal> {
  late List<int> _selectedOwnerIds;
  late List<String> _selectedSegments;
  late DateTimeRange? _dateCreatedRange;
  late DateTimeRange? _lastInteractionRange;

  @override
  void initState() {
    super.initState();
    _selectedOwnerIds = List.from(widget.initialFilters.ownerIds ?? []);
    _selectedSegments = List.from(widget.initialFilters.segments ?? []);
    _dateCreatedRange = _dateRangeToDateTimeRange(widget.initialFilters.createdDateRange);
    _lastInteractionRange = _dateRangeToDateTimeRange(widget.initialFilters.lastInteractionRange);
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

  bool get _hasActiveFilters =>
      _selectedOwnerIds.isNotEmpty ||
      _selectedSegments.isNotEmpty ||
      _dateCreatedRange != null ||
      _lastInteractionRange != null;

  void _applyFilters() {
    final provider = context.read<CustomerProvider>();

    final filters = CustomerFilters(
      ownerIds: _selectedOwnerIds.isNotEmpty ? _selectedOwnerIds : null,
      segments: _selectedSegments.isNotEmpty ? _selectedSegments : null,
      createdDateRange: _dateTimeRangeToDateRange(_dateCreatedRange),
      lastInteractionRange: _dateTimeRangeToDateRange(_lastInteractionRange),
    );

    provider.applyFilters(filters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    final provider = context.read<CustomerProvider>();
    provider.clearFilters();
    Navigator.pop(context);
  }

  Future<void> _selectDateRange(BuildContext context, bool isCreatedDate) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialRange = isCreatedDate ? _dateCreatedRange : _lastInteractionRange;

    final DateTimeRange? picked = await showRangePickerDialog(
      context: context,
      minDate: DateTime(2020),
      maxDate: DateTime.now(),
      selectedRange: initialRange,
      slidersColor: isDark ? ViernesColors.accent : ViernesColors.primary,
      highlightColor: isDark ? ViernesColors.accent : ViernesColors.primary,
      slidersSize: 20,
      splashColor: (isDark ? ViernesColors.accent : ViernesColors.primary).withValues(alpha: 0.1),
      splashRadius: 40,
      centerLeadingDate: true,
      selectedCellsDecoration: BoxDecoration(
        color: isDark ? ViernesColors.accent : ViernesColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      selectedCellsTextStyle: TextStyle(
        color: isDark ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
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
      disabledCellsTextStyle: TextStyle(
        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
        fontSize: 14,
      ),
      enabledCellsTextStyle: TextStyle(
        color: ViernesColors.getTextColor(isDark),
        fontSize: 14,
      ),
      daysOfTheWeekTextStyle: TextStyle(
        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
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

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: ViernesColors.getControlBackground(isDark),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Consumer<CustomerProvider>(
                builder: (context, provider, _) {
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ViernesSpacing.md,
                      vertical: ViernesSpacing.sm,
                    ),
                    children: [
                      _buildOwnerFilter(provider, isDark),
                      const SizedBox(height: ViernesSpacing.md),
                      _buildSegmentFilter(provider, isDark),
                      const SizedBox(height: ViernesSpacing.md),
                      _buildDateCreatedFilter(isDark),
                      const SizedBox(height: ViernesSpacing.md),
                      _buildLastInteractionFilter(isDark),
                      const SizedBox(height: ViernesSpacing.xl),
                    ],
                  );
                },
              ),
            ),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
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
            'Filters',
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

  Widget _buildFooter(bool isDark) {
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
                    onTap: _hasActiveFilters ? _clearFilters : null,
                    borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                    child: Center(
                      child: Text(
                        'Clear Filters',
                        style: ViernesTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _hasActiveFilters
                              ? ViernesColors.getTextColor(isDark)
                              : ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
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
                text: 'Apply Filters',
                onPressed: _applyFilters,
                height: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerFilter(CustomerProvider provider, bool isDark) {
    final owners = provider.availableOwners;
    final options = <Map<String, dynamic>>[
      {'id': -1, 'name': 'Viernes (Unassigned)'},
      ...owners,
    ];

    return _buildFilterSection(
      title: 'Owner/Agent',
      isDark: isDark,
      child: Wrap(
        spacing: ViernesSpacing.sm,
        runSpacing: ViernesSpacing.sm,
        children: options.map((owner) {
          final id = owner['id'] as int;
          final name = owner['name'] as String;
          final isSelected = _selectedOwnerIds.contains(id);
          final isViernes = id == -1;

          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isViernes) ...[
                  Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: isSelected
                        ? ViernesColors.accent
                        : ViernesColors.accent.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(name),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedOwnerIds.add(id);
                } else {
                  _selectedOwnerIds.remove(id);
                }
              });
            },
            selectedColor: (isDark ? ViernesColors.accent : ViernesColors.secondary)
                .withValues(alpha: 0.2),
            checkmarkColor: isDark ? ViernesColors.accent : Colors.black,
            backgroundColor: ViernesColors.getControlBackground(isDark),
            side: BorderSide(
              color: isSelected
                  ? (isDark ? ViernesColors.accent : ViernesColors.secondary)
                  : ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSegmentFilter(CustomerProvider provider, bool isDark) {
    final segments = provider.availableSegments;

    if (segments.isEmpty) {
      return _buildFilterSection(
        title: 'Segment',
        isDark: isDark,
        child: Text(
          'No segments available',
          style: ViernesTextStyles.bodySmall.copyWith(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return _buildFilterSection(
      title: 'Segment',
      isDark: isDark,
      child: Wrap(
        spacing: ViernesSpacing.sm,
        runSpacing: ViernesSpacing.sm,
        children: segments.map((segment) {
          final isSelected = _selectedSegments.contains(segment);

          return FilterChip(
            label: Text(segment),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedSegments.add(segment);
                } else {
                  _selectedSegments.remove(segment);
                }
              });
            },
            selectedColor: (isDark ? ViernesColors.accent : ViernesColors.secondary)
                .withValues(alpha: 0.2),
            checkmarkColor: isDark ? ViernesColors.accent : Colors.black,
            backgroundColor: ViernesColors.getControlBackground(isDark),
            side: BorderSide(
              color: isSelected
                  ? (isDark ? ViernesColors.accent : ViernesColors.secondary)
                  : ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateCreatedFilter(bool isDark) {
    return _buildFilterSection(
      title: 'Date Created',
      isDark: isDark,
      child: _buildDateRangeField(
        label: _dateCreatedRange == null
            ? 'Select date range'
            : _formatDateRange(_dateCreatedRange!),
        isDark: isDark,
        onTap: () => _selectDateRange(context, true),
        onClear: _dateCreatedRange != null
            ? () => setState(() => _dateCreatedRange = null)
            : null,
      ),
    );
  }

  Widget _buildLastInteractionFilter(bool isDark) {
    return _buildFilterSection(
      title: 'Last Interaction',
      isDark: isDark,
      child: _buildDateRangeField(
        label: _lastInteractionRange == null
            ? 'Select date range'
            : _formatDateRange(_lastInteractionRange!),
        isDark: isDark,
        onTap: () => _selectDateRange(context, false),
        onClear: _lastInteractionRange != null
            ? () => setState(() => _lastInteractionRange = null)
            : null,
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
            fontSize: 16,
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        child,
      ],
    );
  }

  Widget _buildDateRangeField({
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                  ),
                  onPressed: onClear,
                )
              : Icon(
                  Icons.calendar_today,
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                ),
        ),
        child: Text(
          label,
          style: ViernesTextStyles.bodyText.copyWith(
            color: onClear != null
                ? ViernesColors.getTextColor(isDark)
                : ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  String _formatDateRange(DateTimeRange range) {
    final startStr = '${range.start.day}/${range.start.month}/${range.start.year}';
    final endStr = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$startStr - $endStr';
  }
}
