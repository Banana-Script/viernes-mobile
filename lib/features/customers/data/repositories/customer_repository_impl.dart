import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_filters.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';

/// Customer Repository Implementation
///
/// Implements the customer repository interface using the remote data source.
/// Preserves custom exceptions from the datasource layer for proper error handling.
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepositoryImpl(this._remoteDataSource);

  @override
  Future<CustomersResponse> getCustomers({
    required PaginationParams pagination,
    required CustomerFilters filters,
    String searchTerm = '',
    int? agentId,
  }) async {
    try {
      return await _remoteDataSource.getCustomers(
        pagination: pagination,
        filters: filters,
        searchTerm: searchTerm,
        agentId: agentId,
      );
    } catch (e, stackTrace) {
      // Re-throw custom exceptions to preserve error information
      if (e is ViernesException) {
        rethrow;
      }

      // Wrap unknown exceptions
      throw NetworkException(
        'Failed to get customers: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<CustomerEntity> getCustomerById(int customerId) async {
    try {
      return await _remoteDataSource.getCustomerById(customerId);
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get customer: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<CustomerEntity> createCustomer({
    required int roleId,
    required int statusId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      return await _remoteDataSource.createCustomer(
        roleId: roleId,
        statusId: statusId,
        userData: userData,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to create customer: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateCustomer({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _remoteDataSource.updateCustomer(
        userId: userId,
        data: data,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to update customer: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteCustomer(int customerId) async {
    try {
      await _remoteDataSource.deleteCustomer(customerId);
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to delete customer: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOwners() async {
    try {
      return await _remoteDataSource.getOwners();
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get owners: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<String>> getSegments() async {
    try {
      return await _remoteDataSource.getSegments();
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get segments: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, int>> getPurchaseIntentions() async {
    try {
      return await _remoteDataSource.getPurchaseIntentions();
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get purchase intentions: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }
}
