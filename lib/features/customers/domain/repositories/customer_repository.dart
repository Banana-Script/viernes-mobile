import '../entities/customer_entity.dart';
import '../entities/customer_filters.dart';

/// Customer Repository
///
/// Repository interface for customer operations.
/// This is in the domain layer and defines the contract that
/// the data layer must implement.
abstract class CustomerRepository {
  /// Get customers list with pagination and filters
  Future<CustomersResponse> getCustomers({
    required PaginationParams pagination,
    required CustomerFilters filters,
    String searchTerm = '',
    int? agentId,
  });

  /// Get customer by ID
  Future<CustomerEntity> getCustomerById(int customerId);

  /// Create new customer
  Future<CustomerEntity> createCustomer({
    required int roleId,
    required int statusId,
    required Map<String, dynamic> userData,
  });

  /// Update customer
  Future<void> updateCustomer({
    required int userId,
    required Map<String, dynamic> data,
  });

  /// Delete customer
  Future<void> deleteCustomer(int customerId);

  /// Get available owners/agents for filtering
  Future<List<Map<String, dynamic>>> getOwners();

  /// Get available segments for filtering
  Future<List<String>> getSegments();

  /// Get purchase intentions statistics
  Future<Map<String, int>> getPurchaseIntentions();
}
