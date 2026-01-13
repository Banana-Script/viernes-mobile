import 'package:dio/dio.dart';
import '../entities/value_definition_entity.dart';
import '../models/value_definition_model.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';
import 'http_client.dart';

/// Value Definitions Service
///
/// Handles fetching and caching of value definitions from the API.
/// Value definitions are used for dynamic configuration values like roles and statuses.
class ValueDefinitionsService {
  final HttpClient _httpClient;
  List<ValueDefinition> _cachedDefinitions = [];
  bool _isLoaded = false;

  ValueDefinitionsService(this._httpClient);

  /// Check if definitions have been loaded
  bool get isLoaded => _isLoaded;

  /// Get all cached definitions
  List<ValueDefinition> get definitions => _cachedDefinitions;

  /// Fetch all value definitions from the API
  ///
  /// This should be called once after login to load all definitions.
  Future<List<ValueDefinition>> loadAllDefinitions() async {
    const endpoint = '/values_definitions/';

    try {
      AppLogger.info('Loading value definitions...', tag: 'ValueDefinitions');

      final response = await _httpClient.dio.get(
        endpoint,
        queryParameters: {
          'page': '1',
          'page_size': '1000',
          'order_by': 'value_definition',
          'order_direction': 'asc',
          'search_term': '',
          'filters': '',
        },
      );

      if (response.statusCode == 200) {
        final parsedResponse = ValueDefinitionsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        _cachedDefinitions = parsedResponse.valueDefinitions;
        _isLoaded = true;

        AppLogger.info(
          'Loaded ${_cachedDefinitions.length} value definitions',
          tag: 'ValueDefinitions',
        );

        return _cachedDefinitions;
      } else {
        throw NetworkException(
          'Failed to load value definitions',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.error(
        'Error loading value definitions: $e',
        tag: 'ValueDefinitions',
        error: e,
        stackTrace: stackTrace,
      );

      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      }

      throw NetworkException(
        'Network error while loading value definitions',
        statusCode: e.response?.statusCode,
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error parsing value definitions: $e',
        tag: 'ValueDefinitions',
        error: e,
        stackTrace: stackTrace,
      );

      if (e is NetworkException || e is UnauthorizedException) rethrow;

      throw ParseException(
        'Error parsing value definitions response: $e',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  /// Get definitions filtered by type
  ///
  /// [definitionType] - The type to filter by (e.g., 'USER_ROLES', 'ORGANIZATION_USER_STATUS')
  List<ValueDefinition> getByType(String definitionType) {
    return _cachedDefinitions
        .where((def) => def.definitionType.definitionType == definitionType)
        .toList();
  }

  /// Find a definition by type and value
  ///
  /// [definitionType] - The type to filter by
  /// [valueDefinition] - The value_definition to find (e.g., '030' for customer role)
  ValueDefinition? findByTypeAndValue(String definitionType, String valueDefinition) {
    return _cachedDefinitions.firstWhere(
      (def) =>
          def.definitionType.definitionType == definitionType &&
          def.valueDefinition == valueDefinition,
      orElse: () => const ValueDefinitionModel(
        id: 0,
        valueDefinition: '',
        description: '',
        active: '0',
        definitionTypeId: 0,
        definitionType: DefinitionTypeModel(
          id: 0,
          definitionType: '',
          description: '',
          active: '0',
        ),
      ),
    );
  }

  /// Get customer role ID
  ///
  /// Returns the ID for USER_ROLES with value_definition '030' (Customer role)
  /// Falls back to 16 if not found
  int getCustomerRoleId() {
    final definition = findByTypeAndValue('USER_ROLES', '030');
    if (definition != null && definition.id != 0) {
      return definition.id;
    }
    AppLogger.warning(
      'Customer role definition not found, using fallback: 16',
      tag: 'ValueDefinitions',
    );
    return 16; // Fallback value
  }

  /// Get active status ID
  ///
  /// Returns the ID for ORGANIZATION_USER_STATUS with value_definition '010' (Active status)
  /// Falls back to 3 if not found
  int getActiveStatusId() {
    final definition = findByTypeAndValue('ORGANIZATION_USER_STATUS', '010');
    if (definition != null && definition.id != 0) {
      return definition.id;
    }
    AppLogger.warning(
      'Active status definition not found, using fallback: 3',
      tag: 'ValueDefinitions',
    );
    return 3; // Fallback value
  }

  /// Clear cached definitions (e.g., on logout)
  void clear() {
    _cachedDefinitions = [];
    _isLoaded = false;
    AppLogger.info('Value definitions cache cleared', tag: 'ValueDefinitions');
  }
}
