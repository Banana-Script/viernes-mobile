import 'package:dio/dio.dart';
import '../../../../core/services/http_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/customer_filters.dart';
import '../models/customer_model.dart';
import '../models/customers_response_model.dart';

/// Customer Remote Data Source
///
/// Handles all HTTP requests related to customers.
abstract class CustomerRemoteDataSource {
  /// Get customers list with pagination and filters
  Future<CustomersResponseModel> getCustomers({
    required PaginationParams pagination,
    required CustomerFilters filters,
    String searchTerm = '',
    int? agentId, // For "My Customers" view
  });

  /// Get customer by ID
  Future<CustomerModel> getCustomerById(int customerId);

  /// Create new customer
  Future<CustomerModel> createCustomer({
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

/// Customer Remote Data Source Implementation
class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final HttpClient _httpClient;

  CustomerRemoteDataSourceImpl(this._httpClient);

  @override
  Future<CustomersResponseModel> getCustomers({
    required PaginationParams pagination,
    required CustomerFilters filters,
    String searchTerm = '',
    int? agentId,
  }) async {
    const endpoint = '/organization_users/customers';

    try {
      // Build query parameters
      final queryParams = {
        ...pagination.toQueryParams(),
        'search_term': searchTerm,
      };

      // Build filter string more safely using structured approach
      final filtersList = <String>[];

      // Add agent filter if provided
      if (agentId != null) {
        // Validate agent ID is positive
        if (agentId <= 0) {
          throw ValidationException(
            'Invalid agent ID',
            fieldErrors: {'agentId': ['Agent ID must be a positive integer']},
          );
        }
        filtersList.add('agent_id=$agentId');
      }

      // Add other filters from CustomerFilters object
      // Parse the toApiString result to extract individual filter parts
      final filtersString = filters.toApiString();
      if (filtersString.isNotEmpty) {
        // Remove brackets and split by comma to get individual filter parts
        final filterContent = filtersString.substring(1, filtersString.length - 1);
        final filterParts = filterContent.split(',');

        // Add filters that don't conflict with agent_id
        for (final part in filterParts) {
          final trimmedPart = part.trim();
          // Skip if it's an agent_id filter (we already added it above if needed)
          if (!trimmedPart.startsWith('agent_id=')) {
            filtersList.add(trimmedPart);
          }
        }
      }

      // Build final filter string
      if (filtersList.isNotEmpty) {
        queryParams['filters'] = '[${filtersList.join(',')}]';
      }

      AppLogger.apiRequest('GET', endpoint, params: queryParams);

      final response = await _httpClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        return CustomersResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to load customers',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException(
          'Request timeout while fetching customers',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Customers endpoint not found',
          resourceType: 'Endpoint',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching customers',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing customers response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<CustomerModel> getCustomerById(int customerId) async {
    const endpoint = '/organization_users/customers';
    final queryParams = {
      'page': '1',
      'page_size': '1',
      'filters': '[id=$customerId]',
    };

    try {
      AppLogger.apiRequest('GET', endpoint, params: queryParams);

      final response = await _httpClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final customers = data['customers'] as List;

        if (customers.isEmpty) {
          throw NotFoundException(
            'Customer not found',
            resourceType: 'Customer',
            resourceId: customerId,
          );
        }

        return CustomerModel.fromJson(customers.first as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to load customer',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Customer not found',
          resourceType: 'Customer',
          resourceId: customerId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching customer',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      if (e is NotFoundException) rethrow;
      throw ParseException(
        'Error parsing customer response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<CustomerModel> createCustomer({
    required int roleId,
    required int statusId,
    required Map<String, dynamic> userData,
  }) async {
    const endpoint = '/organization_users/customer';
    final requestData = {
      'role_id': roleId,
      'status_id': statusId,
      'user': userData,
    };

    try {
      AppLogger.apiRequest('POST', endpoint, params: requestData);

      final response = await _httpClient.dio.post(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CustomerModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to create customer',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid customer data',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while creating customer',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing create customer response: ${e.toString()}',
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
    final endpoint = '/users/$userId';

    try {
      AppLogger.apiRequest('PATCH', endpoint, params: data);

      final response = await _httpClient.dio.patch(
        endpoint,
        data: data,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200) {
        throw NetworkException(
          'Failed to update customer',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Customer not found',
          resourceType: 'Customer',
          resourceId: userId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid update data',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while updating customer',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      if (e is NotFoundException || e is ValidationException || e is UnauthorizedException) rethrow;
      throw NetworkException(
        'Error updating customer: ${e.toString()}',
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteCustomer(int customerId) async {
    final endpoint = '/organization_users/customers/$customerId';

    try {
      AppLogger.apiRequest('DELETE', endpoint);

      final response = await _httpClient.dio.delete(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException(
          'Failed to delete customer',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Customer not found',
          resourceType: 'Customer',
          resourceId: customerId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while deleting customer',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      if (e is NotFoundException || e is UnauthorizedException) rethrow;
      throw NetworkException(
        'Error deleting customer: ${e.toString()}',
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOwners() async {
    const endpoint = '/organization_users/customers/get-owners/';

    try {
      AppLogger.apiRequest('GET', endpoint);

      final response = await _httpClient.dio.get(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['data'] as List).cast<Map<String, dynamic>>();
      } else {
        throw NetworkException(
          'Failed to load owners',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching owners',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing owners response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<String>> getSegments() async {
    const endpoint = '/organization_users/customers/get-segments/';

    try {
      AppLogger.apiRequest('GET', endpoint);

      final response = await _httpClient.dio.get(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['data'] as List).cast<String>();
      } else {
        throw NetworkException(
          'Failed to load segments',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching segments',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing segments response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<Map<String, int>> getPurchaseIntentions() async {
    const endpoint = '/organization_users/customers/get-purchase-intentions/';

    try {
      AppLogger.apiRequest('GET', endpoint);

      final response = await _httpClient.dio.get(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'high': data['high'] as int? ?? 0,
          'medium': data['medium'] as int? ?? 0,
          'low': data['low'] as int? ?? 0,
          'very_high': data['very_high'] as int? ?? 0,
        };
      } else {
        throw NetworkException(
          'Failed to load purchase intentions',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching purchase intentions',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing purchase intentions response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }
}
