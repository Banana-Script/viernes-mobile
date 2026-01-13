import '../entities/customer_entity.dart';
import '../entities/customer_filters.dart';
import '../usecases/get_customer_conversations_usecase.dart';

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

  /// Get customer by user ID
  /// Uses /users/{userId} endpoint which includes optional fields (identification, age, occupation)
  Future<CustomerEntity> getCustomerById(int userId);

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

  /// Get customer conversations (CHAT and CALL history)
  Future<ConversationsResponse> getCustomerConversations({
    required int userId,
    int page = 1,
    int pageSize = 10,
  });
}
