/// Customer Filters
///
/// Represents all available filters for the customer list.
class CustomerFilters {
  final List<int>? ownerIds; // Agent IDs (-1 = unassigned/Viernes)
  final List<String>? segments;
  final DateRange? createdDateRange;
  final DateRange? lastInteractionRange;

  const CustomerFilters({
    this.ownerIds,
    this.segments,
    this.createdDateRange,
    this.lastInteractionRange,
  });

  /// Create empty filters
  factory CustomerFilters.empty() {
    return const CustomerFilters();
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return (ownerIds != null && ownerIds!.isNotEmpty) ||
        (segments != null && segments!.isNotEmpty) ||
        createdDateRange != null ||
        lastInteractionRange != null;
  }

  /// Count active filters
  int get activeFiltersCount {
    int count = 0;
    if (ownerIds != null && ownerIds!.isNotEmpty) count++;
    if (segments != null && segments!.isNotEmpty) count++;
    if (createdDateRange != null) count++;
    if (lastInteractionRange != null) count++;
    return count;
  }

  /// Convert filters to API query string format
  /// Format: [field1=value1,field2=value2|value3,field3>=date1,field3<=date2]
  String toApiString() {
    if (!hasActiveFilters) return '';

    final List<String> filterParts = [];

    // Owner/Agent filter
    if (ownerIds != null && ownerIds!.isNotEmpty) {
      // Validate owner IDs are integers
      for (final id in ownerIds!) {
        if (id < -1) {
          throw ArgumentError('Invalid owner ID: $id');
        }
      }
      final values = ownerIds!.map((id) {
        return id == -1 ? 'null' : id.toString();
      }).join('|');
      filterParts.add('agent_id=$values');
    }

    // Segment filter
    if (segments != null && segments!.isNotEmpty) {
      // Sanitize segment names to prevent injection
      final sanitizedSegments = segments!.map((segment) {
        return _sanitizeFilterValue(segment);
      }).join('|');
      filterParts.add('segment=$sanitizedSegments');
    }

    // Created date filter
    if (createdDateRange != null) {
      if (createdDateRange!.startDate != null) {
        filterParts.add('user.created_at>=${_formatDate(createdDateRange!.startDate!)}');
      }
      if (createdDateRange!.endDate != null) {
        filterParts.add('user.created_at<=${_formatDate(createdDateRange!.endDate!)}');
      }
    }

    // Last interaction filter
    if (lastInteractionRange != null) {
      if (lastInteractionRange!.startDate != null) {
        filterParts.add('user.last_interaction>=${_formatDate(lastInteractionRange!.startDate!)}');
      }
      if (lastInteractionRange!.endDate != null) {
        filterParts.add('user.last_interaction<=${_formatDate(lastInteractionRange!.endDate!)}');
      }
    }

    return '[${filterParts.join(',')}]';
  }

  /// Format date for API (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Sanitize filter value to prevent injection
  /// Removes or escapes characters that could break the filter format:
  /// - Brackets [ ]
  /// - Commas ,
  /// - Pipes |
  /// - Equals =
  String _sanitizeFilterValue(String value) {
    // Replace dangerous characters with safe alternatives
    return value
        .replaceAll('[', '(')
        .replaceAll(']', ')')
        .replaceAll(',', ' ')
        .replaceAll('|', '-')
        .replaceAll('=', '-')
        .trim();
  }

  /// Copy with new values
  CustomerFilters copyWith({
    List<int>? ownerIds,
    List<String>? segments,
    DateRange? createdDateRange,
    DateRange? lastInteractionRange,
    bool clearOwners = false,
    bool clearSegments = false,
    bool clearCreatedDate = false,
    bool clearLastInteraction = false,
  }) {
    return CustomerFilters(
      ownerIds: clearOwners ? null : (ownerIds ?? this.ownerIds),
      segments: clearSegments ? null : (segments ?? this.segments),
      createdDateRange: clearCreatedDate ? null : (createdDateRange ?? this.createdDateRange),
      lastInteractionRange: clearLastInteraction ? null : (lastInteractionRange ?? this.lastInteractionRange),
    );
  }
}

/// Date Range
///
/// Represents a date range for filtering.
class DateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const DateRange({
    this.startDate,
    this.endDate,
  });

  /// Check if range is valid
  bool get isValid {
    if (startDate == null && endDate == null) return false;
    if (startDate != null && endDate != null) {
      return startDate!.isBefore(endDate!) || startDate!.isAtSameMomentAs(endDate!);
    }
    return true;
  }
}

/// Pagination Parameters
///
/// Represents pagination parameters for customer list.
class PaginationParams {
  final int page;
  final int pageSize;
  final String orderBy;
  final OrderDirection orderDirection;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.orderBy = 'created_at',
    this.orderDirection = OrderDirection.desc,
  });

  /// Convert to query parameters map
  Map<String, dynamic> toQueryParams() {
    return {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'order_by': orderBy,
      'order_direction': orderDirection.toApiString(),
    };
  }

  /// Copy with new values
  PaginationParams copyWith({
    int? page,
    int? pageSize,
    String? orderBy,
    OrderDirection? orderDirection,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      orderBy: orderBy ?? this.orderBy,
      orderDirection: orderDirection ?? this.orderDirection,
    );
  }
}

/// Order Direction
enum OrderDirection {
  asc,
  desc;

  String toApiString() {
    return name; // 'asc' or 'desc'
  }

  static OrderDirection fromString(String value) {
    return value.toLowerCase() == 'asc' ? OrderDirection.asc : OrderDirection.desc;
  }
}

/// Customers Response
///
/// Represents the paginated response from the customers API.
class CustomersResponse {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final List<dynamic> customers; // Will be CustomerEntity in data layer

  const CustomersResponse({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.customers,
  });

  /// Check if there are more pages
  bool get hasMorePages => currentPage < totalPages;

  /// Check if this is the last page
  bool get isLastPage => currentPage >= totalPages;
}
