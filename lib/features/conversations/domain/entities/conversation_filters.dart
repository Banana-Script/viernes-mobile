import 'package:flutter/material.dart';
import '../../../customers/domain/entities/conversation_entity.dart';
import '../repositories/conversation_repository.dart';

/// Conversation Filters
///
/// Domain entity for filtering conversations.
/// Supports multiple filter criteria including status, priority, agents, tags, and date range.
class ConversationFilters {
  final List<String> statusIds; // Status filter (open, pending, resolved, etc.)
  final List<String> priorities; // Priority filter (high, medium, low)
  final List<int> agentIds; // Agent filter
  final List<int> tagIds; // Tag filter
  final DateTime? dateFrom; // Date range start
  final DateTime? dateTo; // Date range end
  final bool? unreadOnly; // Show only unread conversations
  final bool? lockedOnly; // Show only locked conversations
  final ConversationType? type; // Filter by type (chat, call)

  const ConversationFilters({
    this.statusIds = const [],
    this.priorities = const [],
    this.agentIds = const [],
    this.tagIds = const [],
    this.dateFrom,
    this.dateTo,
    this.unreadOnly,
    this.lockedOnly,
    this.type,
  });

  /// Check if any filters are active
  bool get hasActiveFilters =>
      statusIds.isNotEmpty ||
      priorities.isNotEmpty ||
      agentIds.isNotEmpty ||
      tagIds.isNotEmpty ||
      dateFrom != null ||
      dateTo != null ||
      unreadOnly == true ||
      lockedOnly == true ||
      type != null;

  /// Count of active filters
  int get activeFilterCount {
    int count = 0;
    if (statusIds.isNotEmpty) count++;
    if (priorities.isNotEmpty) count++;
    if (agentIds.isNotEmpty) count++;
    if (tagIds.isNotEmpty) count++;
    if (dateFrom != null || dateTo != null) count++;
    if (unreadOnly == true) count++;
    if (lockedOnly == true) count++;
    if (type != null) count++;
    return count;
  }

  /// Clear all filters
  ConversationFilters clear() => const ConversationFilters();

  /// Copy with updated filters
  ConversationFilters copyWith({
    List<String>? statusIds,
    List<String>? priorities,
    List<int>? agentIds,
    List<int>? tagIds,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? unreadOnly,
    bool? lockedOnly,
    ConversationType? type,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearUnreadOnly = false,
    bool clearLockedOnly = false,
    bool clearType = false,
  }) {
    return ConversationFilters(
      statusIds: statusIds ?? this.statusIds,
      priorities: priorities ?? this.priorities,
      agentIds: agentIds ?? this.agentIds,
      tagIds: tagIds ?? this.tagIds,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      unreadOnly: clearUnreadOnly ? null : (unreadOnly ?? this.unreadOnly),
      lockedOnly: clearLockedOnly ? null : (lockedOnly ?? this.lockedOnly),
      type: clearType ? null : (type ?? this.type),
    );
  }

  /// Convert to API filter string format
  /// Format: [filter1=value1,filter2=value2,...]
  /// Multiple values use pipe separator: status_id=1|2|3
  String toApiString() {
    final filters = <String>[];

    // Status filter - use pipe for multiple values
    if (statusIds.isNotEmpty) {
      filters.add('status_id=${statusIds.join('|')}');
    }

    // Priority filter - use pipe for multiple values
    if (priorities.isNotEmpty) {
      filters.add('priority=${priorities.join('|')}');
    }

    // Agent filter - use pipe, convert -1 to "null|-1" for Viernes (unassigned)
    if (agentIds.isNotEmpty) {
      final agentValues = agentIds.map((id) => id == -1 ? 'null|-1' : '$id').join('|');
      filters.add('agent_id=$agentValues');
    }

    // Tag filter - use pipe for multiple values
    if (tagIds.isNotEmpty) {
      filters.add('tag_id=${tagIds.join('|')}');
    }

    // Date range filters - use >= and <= with correct format
    if (dateFrom != null) {
      filters.add('created_at>=${_formatDateForApi(dateFrom!)}');
    }
    if (dateTo != null) {
      filters.add('created_at<=${_formatDateForApi(dateTo!, endOfDay: true)}');
    }

    // Unread filter
    if (unreadOnly == true) {
      filters.add('readed=0');
    }

    // Locked filter
    if (lockedOnly == true) {
      filters.add('locked=true');
    }

    // Type filter
    if (type != null) {
      filters.add('type=${type!.toApiString()}');
    }

    return filters.isEmpty ? '' : '[${filters.join(',')}]';
  }

  /// Format date for API: YYYY-MM-DD HH:MM:SS
  String _formatDateForApi(DateTime date, {bool endOfDay = false}) {
    final d = endOfDay
        ? DateTime(date.year, date.month, date.day, 23, 59, 59)
        : DateTime(date.year, date.month, date.day, 0, 0, 0);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';
  }

  /// Get active filter labels for display
  List<ActiveFilter> getActiveFilterLabels({
    List<ConversationStatusOption>? availableStatuses,
    List<AgentOption>? availableAgents,
  }) {
    final labels = <ActiveFilter>[];

    // Status filters
    for (final statusId in statusIds) {
      String statusLabel = statusId;
      try {
        final statusOption = availableStatuses?.firstWhere(
          (s) => s.id.toString() == statusId,
        );
        statusLabel = statusOption?.description ?? statusId;
      } catch (_) {
        // Status not found, use ID as fallback
      }
      labels.add(ActiveFilter(
        label: statusLabel,
        color: _getStatusColor(statusId),
        type: FilterType.status,
        value: statusId,
      ));
    }

    // Priority filters
    for (final priority in priorities) {
      labels.add(ActiveFilter(
        label: priority.toUpperCase(),
        color: _getPriorityColor(priority),
        type: FilterType.priority,
        value: priority,
      ));
    }

    // Agent filters - show name if single, count if multiple
    if (agentIds.isNotEmpty) {
      String agentLabel;
      if (agentIds.length == 1) {
        final agentId = agentIds.first;
        if (agentId == -1) {
          agentLabel = 'Viernes';
        } else {
          try {
            final agent = availableAgents?.firstWhere((a) => a.id == agentId);
            agentLabel = agent?.name ?? 'Agent';
          } catch (_) {
            agentLabel = 'Agent';
          }
        }
      } else {
        agentLabel = '${agentIds.length} Agents';
      }
      labels.add(ActiveFilter(
        label: agentLabel,
        color: const Color(0xFF51F5F8), // Accent cyan
        type: FilterType.agent,
        value: agentIds.join(','),
      ));
    }

    // Tag filters (show count if multiple)
    if (tagIds.isNotEmpty) {
      labels.add(ActiveFilter(
        label: tagIds.length == 1 ? 'Tag' : '${tagIds.length} Tags',
        color: const Color(0xFF2196F3), // Info blue
        type: FilterType.tag,
        value: tagIds.join(','),
      ));
    }

    // Date range filter
    if (dateFrom != null || dateTo != null) {
      labels.add(const ActiveFilter(
        label: 'Date Range',
        color: Color(0xFF9CA3AF), // Gray
        type: FilterType.dateRange,
        value: 'date',
      ));
    }

    // Unread filter
    if (unreadOnly == true) {
      labels.add(const ActiveFilter(
        label: 'Unread',
        color: Color(0xFF51F5F8), // Accent cyan
        type: FilterType.unread,
        value: 'unread',
      ));
    }

    // Type filter
    if (type != null) {
      labels.add(ActiveFilter(
        label: type == ConversationType.chat ? 'Chats' : 'Calls',
        color: const Color(0xFF2196F3), // Info blue
        type: FilterType.type,
        value: type!.toApiString(),
      ));
    }

    return labels;
  }

  Color _getStatusColor(String statusId) {
    switch (statusId.toLowerCase()) {
      case '1':
      case 'open':
        return const Color(0xFF16A34A); // Success green
      case '2':
      case 'pending':
        return const Color(0xFFE2A03F); // Warning orange
      case '3':
      case 'resolved':
        return const Color(0xFF2196F3); // Info blue
      case '4':
      case 'abandoned':
        return const Color(0xFF64748B); // Gray
      default:
        return const Color(0xFF9CA3AF); // Default gray
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE7515A); // Danger red
      case 'medium':
        return const Color(0xFFE2A03F); // Warning orange
      case 'low':
        return const Color(0xFF2196F3); // Info blue
      default:
        return const Color(0xFF9CA3AF); // Gray
    }
  }
}

/// Active Filter for display
class ActiveFilter {
  final String label;
  final Color color;
  final FilterType type;
  final String value;

  const ActiveFilter({
    required this.label,
    required this.color,
    required this.type,
    required this.value,
  });
}

/// Filter Type
enum FilterType {
  status,
  priority,
  agent,
  tag,
  dateRange,
  unread,
  type,
}
