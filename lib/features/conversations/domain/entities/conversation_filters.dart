import 'package:flutter/material.dart';
import '../../../customers/domain/entities/conversation_entity.dart';

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
  String toApiString() {
    final filters = <String>[];

    // Status filter
    for (final statusId in statusIds) {
      filters.add('status_id=$statusId');
    }

    // Priority filter
    for (final priority in priorities) {
      filters.add('priority=$priority');
    }

    // Agent filter
    for (final agentId in agentIds) {
      filters.add('agent_id=$agentId');
    }

    // Tag filter
    for (final tagId in tagIds) {
      filters.add('tag_id=$tagId');
    }

    // Date range filters
    if (dateFrom != null) {
      filters.add('created_at_from=${dateFrom!.toIso8601String()}');
    }
    if (dateTo != null) {
      filters.add('created_at_to=${dateTo!.toIso8601String()}');
    }

    // Unread filter
    if (unreadOnly == true) {
      filters.add('readed=false');
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

  /// Get active filter labels for display
  List<ActiveFilter> getActiveFilterLabels() {
    final labels = <ActiveFilter>[];

    // Status filters
    for (final statusId in statusIds) {
      labels.add(ActiveFilter(
        label: _getStatusLabel(statusId),
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

    // Agent filters (show count if multiple)
    if (agentIds.isNotEmpty) {
      labels.add(ActiveFilter(
        label: agentIds.length == 1 ? 'Agent' : '${agentIds.length} Agents',
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

  String _getStatusLabel(String statusId) {
    // Map status IDs to labels - adjust based on your API
    switch (statusId.toLowerCase()) {
      case '1':
      case 'open':
        return 'OPEN';
      case '2':
      case 'pending':
        return 'PENDING';
      case '3':
      case 'resolved':
        return 'RESOLVED';
      case '4':
      case 'abandoned':
        return 'ABANDONED';
      default:
        return statusId.toUpperCase();
    }
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
