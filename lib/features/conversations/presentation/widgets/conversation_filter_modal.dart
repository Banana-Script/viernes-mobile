import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../../domain/entities/conversation_filters.dart';
import '../providers/conversation_provider.dart';

/// Conversation Filter Modal
///
/// Bottom sheet modal for filtering conversations by status, priority, agent, tags, and date range.
class ConversationFilterModal extends StatefulWidget {
  final ConversationFilters initialFilters;

  const ConversationFilterModal({
    super.key,
    required this.initialFilters,
  });

  @override
  State<ConversationFilterModal> createState() => _ConversationFilterModalState();
}

class _ConversationFilterModalState extends State<ConversationFilterModal> {
  late ConversationFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _applyFilters() {
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    provider.applyFilters(_filters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    final provider = Provider.of<ConversationProvider>(context, listen: false);
    provider.clearFilters();
    Navigator.pop(context);
  }

  String _getPriorityLabel(String priority, AppLocalizations? l10n) {
    switch (priority) {
      case 'high':
        return l10n?.priorityHigh ?? 'HIGH';
      case 'medium':
        return l10n?.priorityMedium ?? 'MEDIUM';
      case 'low':
        return l10n?.priorityLow ?? 'LOW';
      default:
        return priority.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
            _buildHeader(isDark, l10n),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: ViernesSpacing.md,
                  vertical: ViernesSpacing.sm,
                ),
                children: [
                  _buildStatusFilter(isDark, l10n),
                  const SizedBox(height: ViernesSpacing.md),
                  // Agent filter - only show in "All Conversations" mode
                  Consumer<ConversationProvider>(
                    builder: (context, provider, _) {
                      if (provider.viewMode == ConversationViewMode.all) {
                        return Column(
                          children: [
                            _buildAgentFilter(isDark, l10n),
                            const SizedBox(height: ViernesSpacing.md),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  _buildPriorityFilter(isDark, l10n),
                  const SizedBox(height: ViernesSpacing.md),
                  _buildTagFilter(isDark, l10n),
                  const SizedBox(height: ViernesSpacing.md),
                  _buildDateRangeFilter(isDark, l10n),
                  const SizedBox(height: ViernesSpacing.xl),
                ],
              ),
            ),
            _buildFooter(isDark, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations? l10n) {
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
            l10n?.filtersTitle ?? 'Filters',
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

  Widget _buildFooter(bool isDark, AppLocalizations? l10n) {
    final hasActiveFilters = _filters.hasActiveFilters;

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
                    onTap: hasActiveFilters ? _clearFilters : null,
                    borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                    child: Center(
                      child: Text(
                        l10n?.clearFiltersButton ?? 'Clear Filters',
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
                text: l10n?.applyFiltersButton ?? 'Apply Filters',
                onPressed: _applyFilters,
                height: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(bool isDark, AppLocalizations? l10n) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final statuses = provider.availableStatuses;

        return _buildFilterSection(
          title: l10n?.filterStatus ?? 'Status',
          isDark: isDark,
          child: Wrap(
            spacing: ViernesSpacing.sm,
            runSpacing: ViernesSpacing.sm,
            children: statuses.map((status) {
              final isSelected = _filters.statusIds.contains(status.id.toString());

              final selectedColor = isDark ? ViernesColors.accent : ViernesColors.secondary;

              return FilterChip(
                label: Text(status.description),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filters = _filters.copyWith(
                        statusIds: [..._filters.statusIds, status.id.toString()],
                      );
                    } else {
                      final newStatuses = List<String>.from(_filters.statusIds);
                      newStatuses.remove(status.id.toString());
                      _filters = _filters.copyWith(statusIds: newStatuses);
                    }
                  });
                },
                selectedColor: selectedColor.withValues(alpha: 0.2),
                checkmarkColor: isDark ? ViernesColors.accent : Colors.black,
                backgroundColor: ViernesColors.getControlBackground(isDark),
                side: BorderSide(
                  color: isSelected
                      ? selectedColor
                      : ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPriorityFilter(bool isDark, AppLocalizations? l10n) {
    final priorities = ['high', 'medium', 'low'];
    final priorityColors = {
      'high': ViernesColors.danger,
      'medium': ViernesColors.warning,
      'low': ViernesColors.info,
    };

    return _buildFilterSection(
      title: l10n?.filterPriority ?? 'Priority',
      isDark: isDark,
      child: Wrap(
        spacing: ViernesSpacing.sm,
        runSpacing: ViernesSpacing.sm,
        children: priorities.map((priority) {
          final isSelected = _filters.priorities.contains(priority);

          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: priorityColors[priority],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(_getPriorityLabel(priority, l10n)),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _filters = _filters.copyWith(
                    priorities: [..._filters.priorities, priority],
                  );
                } else {
                  final newPriorities = List<String>.from(_filters.priorities);
                  newPriorities.remove(priority);
                  _filters = _filters.copyWith(priorities: newPriorities);
                }
              });
            },
            selectedColor: priorityColors[priority]!.withValues(alpha: 0.2),
            checkmarkColor: priorityColors[priority],
            backgroundColor: ViernesColors.getControlBackground(isDark),
            side: BorderSide(
              color: isSelected
                  ? priorityColors[priority]!
                  : ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAgentFilter(bool isDark, AppLocalizations? l10n) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final agents = provider.availableAgents;

        return _buildFilterSection(
          title: l10n?.filterAssignedTo ?? 'Assigned To',
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Viernes (unassigned) option
              CheckboxListTile(
                title: Row(
                  children: [
                    const Icon(
                      Icons.smart_toy,
                      size: 20,
                      color: ViernesColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n?.viernesUnassignedFilter ?? 'Viernes (Unassigned)'),
                  ],
                ),
                value: _filters.agentIds.contains(-1),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _filters = _filters.copyWith(
                        agentIds: [..._filters.agentIds, -1],
                      );
                    } else {
                      final newAgents = List<int>.from(_filters.agentIds);
                      newAgents.remove(-1);
                      _filters = _filters.copyWith(agentIds: newAgents);
                    }
                  });
                },
                activeColor: ViernesColors.accent,
                contentPadding: EdgeInsets.zero,
              ),
              ...agents.map((agent) {
                final isSelected = _filters.agentIds.contains(agent.id);

                return CheckboxListTile(
                  title: Text(agent.name),
                  value: isSelected,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        _filters = _filters.copyWith(
                          agentIds: [..._filters.agentIds, agent.id],
                        );
                      } else {
                        final newAgents = List<int>.from(_filters.agentIds);
                        newAgents.remove(agent.id);
                        _filters = _filters.copyWith(agentIds: newAgents);
                      }
                    });
                  },
                  activeColor: ViernesColors.accent,
                  contentPadding: EdgeInsets.zero,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTagFilter(bool isDark, AppLocalizations? l10n) {
    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final tags = provider.availableTags;

        if (tags.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildFilterSection(
          title: l10n?.filterTags ?? 'Tags',
          isDark: isDark,
          child: Wrap(
            spacing: ViernesSpacing.sm,
            runSpacing: ViernesSpacing.sm,
            children: tags.map((tag) {
              final isSelected = _filters.tagIds.contains(tag.id);

              return FilterChip(
                label: Text(tag.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filters = _filters.copyWith(
                        tagIds: [..._filters.tagIds, tag.id],
                      );
                    } else {
                      final newTags = List<int>.from(_filters.tagIds);
                      newTags.remove(tag.id);
                      _filters = _filters.copyWith(tagIds: newTags);
                    }
                  });
                },
                selectedColor: ViernesColors.secondary.withValues(alpha: 0.3),
                checkmarkColor: Colors.black,
                backgroundColor: ViernesColors.getControlBackground(isDark),
                side: BorderSide(
                  color: isSelected
                      ? ViernesColors.secondary
                      : ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDateRangeFilter(bool isDark, AppLocalizations? l10n) {
    return _buildFilterSection(
      title: l10n?.filterDateRange ?? 'Conversation Start Date',
      isDark: isDark,
      child: Row(
        children: [
          Expanded(
            child: _buildDateField(
              label: l10n?.from ?? 'From',
              date: _filters.dateFrom,
              isDark: isDark,
              l10n: l10n,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _filters.dateFrom ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _filters = _filters.copyWith(dateFrom: picked);
                  });
                }
              },
            ),
          ),
          const SizedBox(width: ViernesSpacing.md),
          Expanded(
            child: _buildDateField(
              label: l10n?.to ?? 'To',
              date: _filters.dateTo,
              isDark: isDark,
              l10n: l10n,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _filters.dateTo ?? DateTime.now(),
                  firstDate: _filters.dateFrom ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _filters = _filters.copyWith(dateTo: picked);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required bool isDark,
    required AppLocalizations? l10n,
    required VoidCallback onTap,
  }) {
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
          date != null ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' : (l10n?.selectDate ?? 'Select date'),
          style: ViernesTextStyles.bodyText.copyWith(
            color: date != null
                ? ViernesColors.getTextColor(isDark)
                : ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
          ),
        ),
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
}
