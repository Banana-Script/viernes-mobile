import 'package:flutter/foundation.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/customer_filters.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/get_customer_by_id_usecase.dart';
import '../../domain/usecases/get_filter_options_usecase.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

enum CustomerStatus { initial, loading, loaded, loadingMore, error }

class CustomerProvider extends ChangeNotifier {
  final GetCustomersUseCase _getCustomersUseCase;
  final GetCustomerByIdUseCase _getCustomerByIdUseCase;
  final GetFilterOptionsUseCase _getFilterOptionsUseCase;
  final CreateCustomerUseCase _createCustomerUseCase;
  final UpdateCustomerUseCase _updateCustomerUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;

  CustomerProvider({
    required GetCustomersUseCase getCustomersUseCase,
    required GetCustomerByIdUseCase getCustomerByIdUseCase,
    required GetFilterOptionsUseCase getFilterOptionsUseCase,
    required CreateCustomerUseCase createCustomerUseCase,
    required UpdateCustomerUseCase updateCustomerUseCase,
    required DeleteCustomerUseCase deleteCustomerUseCase,
  })  : _getCustomersUseCase = getCustomersUseCase,
        _getCustomerByIdUseCase = getCustomerByIdUseCase,
        _getFilterOptionsUseCase = getFilterOptionsUseCase,
        _createCustomerUseCase = createCustomerUseCase,
        _updateCustomerUseCase = updateCustomerUseCase,
        _deleteCustomerUseCase = deleteCustomerUseCase;

  // State management
  CustomerStatus _status = CustomerStatus.initial;
  String? _errorMessage;

  // Customer list data
  List<CustomerEntity> _customers = [];
  int _totalCount = 0;
  int _totalPages = 0;
  int _currentPage = 1;
  int _pageSize = 20;

  // Filter data
  CustomerFilters _filters = const CustomerFilters();
  String _searchTerm = '';
  int? _agentId; // For "My Customers" view

  // Filter options
  List<Map<String, dynamic>> _availableOwners = [];
  List<String> _availableSegments = [];
  Map<String, int> _purchaseIntentions = {};

  // Selected customer for detail view
  CustomerEntity? _selectedCustomer;

  // View mode
  bool _showMyCustomersOnly = false;

  // Getters
  CustomerStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<CustomerEntity> get customers => _customers;
  int get totalCount => _totalCount;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  CustomerFilters get filters => _filters;
  String get searchTerm => _searchTerm;
  int? get agentId => _agentId;
  List<Map<String, dynamic>> get availableOwners => _availableOwners;
  List<String> get availableSegments => _availableSegments;
  Map<String, int> get purchaseIntentions => _purchaseIntentions;
  CustomerEntity? get selectedCustomer => _selectedCustomer;
  bool get showMyCustomersOnly => _showMyCustomersOnly;
  bool get hasMorePages => _currentPage < _totalPages;
  bool get isLoading => _status == CustomerStatus.loading;
  bool get isLoadingMore => _status == CustomerStatus.loadingMore;

  /// Initialize customer list
  Future<void> initialize({int? currentAgentId}) async {
    if (_status == CustomerStatus.loading) return;

    _agentId = currentAgentId;

    // Load filter options first
    await _loadFilterOptions();

    // Then load customers
    await loadCustomers(resetPage: true);
  }

  /// Load customers with current filters
  Future<void> loadCustomers({bool resetPage = false}) async {
    if (_status == CustomerStatus.loading) return;

    if (resetPage) {
      _currentPage = 1;
      _customers = [];
    }

    _status = CustomerStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final pagination = PaginationParams(
        page: _currentPage,
        pageSize: _pageSize,
        orderBy: 'created_at',
        orderDirection: OrderDirection.desc,
      );

      final response = await _getCustomersUseCase(
        pagination: pagination,
        filters: _filters,
        searchTerm: _searchTerm,
        agentId: _showMyCustomersOnly ? _agentId : null,
      );

      _customers = response.customers.cast<CustomerEntity>();
      _totalCount = response.totalCount;
      _totalPages = response.totalPages;
      _currentPage = response.currentPage;
      _pageSize = response.pageSize;

      _status = CustomerStatus.loaded;
    } catch (e, stackTrace) {
      _status = CustomerStatus.error;
      _errorMessage = e.toString();
      AppLogger.error(
        'Error loading customers: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }

    notifyListeners();
  }

  /// Load more customers (pagination)
  Future<void> loadMoreCustomers() async {
    if (!hasMorePages || _status == CustomerStatus.loadingMore) return;

    _status = CustomerStatus.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final pagination = PaginationParams(
        page: nextPage,
        pageSize: _pageSize,
        orderBy: 'created_at',
        orderDirection: OrderDirection.desc,
      );

      final response = await _getCustomersUseCase(
        pagination: pagination,
        filters: _filters,
        searchTerm: _searchTerm,
        agentId: _showMyCustomersOnly ? _agentId : null,
      );

      _customers.addAll(response.customers.cast<CustomerEntity>());
      _currentPage = response.currentPage;

      _status = CustomerStatus.loaded;
    } catch (e, stackTrace) {
      _status = CustomerStatus.error;
      _errorMessage = e.toString();
      AppLogger.error(
        'Error loading more customers: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
    }

    notifyListeners();
  }

  /// Refresh customer list
  Future<void> refresh() async {
    await loadCustomers(resetPage: true);
  }

  /// Update search term
  void updateSearchTerm(String term) {
    if (_searchTerm == term) return;
    _searchTerm = term;
    notifyListeners();
  }

  /// Apply search (triggers new query)
  Future<void> applySearch() async {
    await loadCustomers(resetPage: true);
  }

  /// Update filters
  void updateFilters(CustomerFilters newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  /// Apply filters (triggers new query)
  Future<void> applyFilters(CustomerFilters newFilters) async {
    _filters = newFilters;
    await loadCustomers(resetPage: true);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _filters = const CustomerFilters();
    _searchTerm = '';
    await loadCustomers(resetPage: true);
  }

  /// Toggle between All/My Customers view
  Future<void> toggleMyCustomers(bool showMy) async {
    if (_showMyCustomersOnly == showMy) return;
    _showMyCustomersOnly = showMy;
    await loadCustomers(resetPage: true);
  }

  /// Load filter options (owners, segments, purchase intentions)
  Future<void> _loadFilterOptions() async {
    try {
      final results = await Future.wait([
        _getFilterOptionsUseCase.getOwners(),
        _getFilterOptionsUseCase.getSegments(),
        _getFilterOptionsUseCase.getPurchaseIntentions(),
      ]);

      _availableOwners = results[0] as List<Map<String, dynamic>>;
      _availableSegments = results[1] as List<String>;
      _purchaseIntentions = results[2] as Map<String, int>;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error loading filter options: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't throw, allow customers to load
    }
  }

  /// Get customer by user ID
  ///
  /// Note: The /users/{userId} endpoint doesn't return last_conversation,
  /// so we preserve it from the existing customer in the list if available.
  Future<void> getCustomerById(int userId) async {
    try {
      final freshCustomer = await _getCustomerByIdUseCase(userId);

      // Try to preserve lastConversation from the list (since /users/{userId} doesn't return it)
      final existingCustomer = _customers.cast<CustomerEntity?>().firstWhere(
        (c) => c?.userId == userId,
        orElse: () => null,
      );

      if (existingCustomer?.lastConversation != null && freshCustomer.lastConversation == null) {
        // Merge: use fresh data but keep lastConversation from list
        _selectedCustomer = CustomerEntity(
          id: freshCustomer.id,
          userId: freshCustomer.userId,
          name: freshCustomer.name,
          email: freshCustomer.email,
          phoneNumber: freshCustomer.phoneNumber,
          identification: freshCustomer.identification,
          age: freshCustomer.age,
          occupation: freshCustomer.occupation,
          createdAt: freshCustomer.createdAt,
          segment: freshCustomer.segment ?? existingCustomer?.segment,
          segmentSummary: freshCustomer.segmentSummary ?? existingCustomer?.segmentSummary,
          segmentDescription: freshCustomer.segmentDescription ?? existingCustomer?.segmentDescription,
          segmentDate: freshCustomer.segmentDate ?? existingCustomer?.segmentDate,
          lastInteraction: freshCustomer.lastInteraction ?? existingCustomer?.lastInteraction,
          insightsInfo: freshCustomer.insightsInfo.isNotEmpty
              ? freshCustomer.insightsInfo
              : existingCustomer?.insightsInfo ?? const [],
          assignedAgent: freshCustomer.assignedAgent ?? existingCustomer?.assignedAgent,
          lastConversation: existingCustomer!.lastConversation, // Preserve from list
        );
      } else {
        _selectedCustomer = freshCustomer;
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load customer: $e';
      AppLogger.error(
        'Error getting customer by ID: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
    }
  }

  /// Create new customer
  Future<bool> createCustomer({
    required int roleId,
    required int statusId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final newCustomer = await _createCustomerUseCase(
        roleId: roleId,
        statusId: statusId,
        userData: userData,
      );

      // Add to list and refresh
      _customers.insert(0, newCustomer);
      _totalCount++;
      notifyListeners();

      return true;
    } on ValidationException catch (e, stackTrace) {
      // Show validation error message directly (e.g., "User already has access to the organization")
      _errorMessage = e.message;
      AppLogger.error(
        'Error creating customer: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to create customer: $e';
      AppLogger.error(
        'Error creating customer: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Update customer
  Future<bool> updateCustomer({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _updateCustomerUseCase(
        userId: userId,
        data: data,
      );

      // Refresh the customer in the list
      final index = _customers.indexWhere((c) => c.userId == userId);
      if (index != -1) {
        // Reload customer data using userId (not organization_user id)
        final updatedCustomer = await _getCustomerByIdUseCase(_customers[index].userId);
        _customers[index] = updatedCustomer;

        if (_selectedCustomer?.userId == userId) {
          _selectedCustomer = updatedCustomer;
        }
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update customer: $e';
      AppLogger.error(
        'Error updating customer: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Delete customer
  Future<bool> deleteCustomer(int customerId) async {
    try {
      await _deleteCustomerUseCase(customerId);

      // Remove from list
      _customers.removeWhere((c) => c.id == customerId);
      _totalCount--;

      if (_selectedCustomer?.id == customerId) {
        _selectedCustomer = null;
      }

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete customer: $e';
      AppLogger.error(
        'Error deleting customer: $e',
        tag: 'CustomerProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Retry loading data
  Future<void> retry() async {
    _status = CustomerStatus.initial;
    _errorMessage = null;
    await loadCustomers(resetPage: true);
  }

  /// Clear selected customer
  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }
}
