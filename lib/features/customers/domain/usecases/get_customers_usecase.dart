import '../../../../core/errors/exceptions.dart';
import '../entities/customer_filters.dart';
import '../repositories/customer_repository.dart';

/// Get Customers Use Case
///
/// Retrieves a paginated list of customers with optional filters and search.
class GetCustomersUseCase {
  final CustomerRepository _repository;

  GetCustomersUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [pagination]: Pagination parameters (page, pageSize, orderBy, orderDirection)
  /// - [filters]: Filter criteria (owner, segment, date ranges)
  /// - [searchTerm]: Search term to filter customers by name, email, or phone
  /// - [agentId]: Optional agent ID for "My Customers" view
  ///
  /// Throws:
  /// - [ValidationException] if input parameters are invalid
  Future<CustomersResponse> call({
    required PaginationParams pagination,
    required CustomerFilters filters,
    String searchTerm = '',
    int? agentId,
  }) async {
    // Validate pagination parameters
    _validatePagination(pagination);

    // Validate search term
    _validateSearchTerm(searchTerm);

    // Validate agent ID if provided
    if (agentId != null) {
      _validateAgentId(agentId);
    }

    return await _repository.getCustomers(
      pagination: pagination,
      filters: filters,
      searchTerm: searchTerm,
      agentId: agentId,
    );
  }

  void _validatePagination(PaginationParams pagination) {
    final errors = <String, List<String>>{};

    if (pagination.page < 1) {
      errors['page'] = ['Page must be greater than or equal to 1'];
    }

    if (pagination.pageSize < 1 || pagination.pageSize > 100) {
      errors['pageSize'] = ['Page size must be between 1 and 100'];
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        'Invalid pagination parameters',
        fieldErrors: errors,
      );
    }
  }

  void _validateSearchTerm(String searchTerm) {
    if (searchTerm.length > 200) {
      throw ValidationException(
        'Search term is too long',
        fieldErrors: {
          'searchTerm': ['Search term must be 200 characters or less']
        },
      );
    }
  }

  void _validateAgentId(int agentId) {
    if (agentId <= 0) {
      throw ValidationException(
        'Invalid agent ID',
        fieldErrors: {
          'agentId': ['Agent ID must be a positive integer']
        },
      );
    }
  }
}
