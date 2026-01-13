import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';
import '../utils/timezone_utils.dart';
import 'http_client.dart';

/// Organization Timezone Service
///
/// Handles fetching the organization's timezone from the API.
/// Endpoint: GET /organizations/timezone
/// Response: { "timezone": "America/Bogota" }
class OrganizationTimezoneService {
  final HttpClient _httpClient;
  String? _cachedTimezone;
  bool _isLoaded = false;

  OrganizationTimezoneService(this._httpClient);

  /// Check if timezone has been loaded
  bool get isLoaded => _isLoaded;

  /// Get cached timezone
  String? get timezone => _cachedTimezone;

  /// Fetch organization timezone from the API
  ///
  /// This should be called once after login to load the organization's timezone.
  /// Returns the IANA timezone string (e.g., "America/Bogota")
  Future<String?> loadTimezone() async {
    const endpoint = '/organizations/timezone';

    try {
      AppLogger.info('Loading organization timezone...', tag: 'OrgTimezone');

      final response = await _httpClient.dio.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final receivedTimezone = data['timezone'] as String?;

        // Validate timezone string is a valid IANA timezone
        if (TimezoneUtils.isValidTimezone(receivedTimezone)) {
          _cachedTimezone = receivedTimezone;
          AppLogger.info(
            'Loaded organization timezone: $_cachedTimezone',
            tag: 'OrgTimezone',
          );
        } else {
          AppLogger.warning(
            'Invalid timezone received from API: $receivedTimezone, ignoring',
            tag: 'OrgTimezone',
          );
          _cachedTimezone = null;
        }

        _isLoaded = true;
        return _cachedTimezone;
      } else {
        throw NetworkException(
          'Failed to load organization timezone',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.error(
        'Error loading organization timezone: $e',
        tag: 'OrgTimezone',
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

      // Don't throw for timezone - it's not critical
      // The app can fallback to device timezone
      AppLogger.warning(
        'Could not load organization timezone, will use device timezone',
        tag: 'OrgTimezone',
      );
      _isLoaded = true;
      return null;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error parsing organization timezone: $e',
        tag: 'OrgTimezone',
        error: e,
        stackTrace: stackTrace,
      );

      // Don't throw - fallback to device timezone
      _isLoaded = true;
      return null;
    }
  }

  /// Clear cached timezone (e.g., on logout)
  void clear() {
    _cachedTimezone = null;
    _isLoaded = false;
    AppLogger.info('Organization timezone cache cleared', tag: 'OrgTimezone');
  }
}
