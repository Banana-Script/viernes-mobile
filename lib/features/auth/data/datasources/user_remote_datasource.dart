import 'package:dio/dio.dart';
import '../../../../core/services/http_client.dart';
import '../models/organization_model.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Fetches the complete user profile from the backend
  /// Uses the Firebase token to identify the user via /users/me endpoint
  Future<UserModel> getUserProfile();

  /// Changes the agent availability status
  /// userId: The database user ID (e.g., 660, NOT the organization_users.id)
  /// isAvailable: true for active (010), false for inactive (020)
  Future<void> changeAgentAvailability(int userId, bool isAvailable);

  /// Fetches the organization info for the logged user
  /// Uses the /organizations/logged/user endpoint
  Future<OrganizationModel> getOrganizationInfo();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient _httpClient;

  UserRemoteDataSourceImpl({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  @override
  Future<UserModel> getUserProfile() async {
    try {
      // Using /users/me endpoint - it uses the Bearer token to identify the user
      final response = await _httpClient.dio.get('/users/me');

      if (response.statusCode == 200) {
        // Parse the backend response with nested structure
        return UserModel.fromBackendJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch user profile',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch user profile');
    } catch (e) {
      throw Exception('Unexpected error occurred while fetching user profile: $e');
    }
  }

  @override
  Future<void> changeAgentAvailability(int userId, bool isAvailable) async {
    try {
      // Endpoint: POST /organization_users/change_agent_availability/{userId}/{isAvailable}
      // userId: The user.id from the database (e.g., 660)
      // isAvailable: boolean (true/false)
      final response = await _httpClient.dio.post(
        '/organization_users/change_agent_availability/$userId/$isAvailable',
        data: {}, // Empty body as specified
      );

      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to change agent availability',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to change agent availability');
    } catch (e) {
      throw Exception('Unexpected error occurred while changing agent availability: $e');
    }
  }

  @override
  Future<OrganizationModel> getOrganizationInfo() async {
    try {
      final response = await _httpClient.dio.get('/organizations/logged/user');

      if (response.statusCode == 200) {
        return OrganizationModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch organization info',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch organization info');
    } catch (e) {
      throw Exception('Unexpected error occurred while fetching organization info: $e');
    }
  }

  Exception _handleDioError(DioException e, String defaultMessage) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 401:
            return Exception('Authentication failed. Please log in again.');
          case 403:
            return Exception('You do not have permission to access this resource.');
          case 404:
            return Exception('User profile not found.');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception('$defaultMessage (Status: $statusCode)');
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true) {
          return Exception('No internet connection. Please check your network.');
        }
        return Exception('$defaultMessage. Please try again.');
      default:
        return Exception(defaultMessage);
    }
  }
}
