import 'package:dio/dio.dart';
import '../../../../core/services/http_client.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Fetches the complete user profile from the backend
  /// Uses the Firebase UID to get the user data
  Future<UserModel> getUserProfile(String uid);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient _httpClient;

  UserRemoteDataSourceImpl({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  @override
  Future<UserModel> getUserProfile(String uid) async {
    try {
      // Using /users/{uid} endpoint as specified in the migration guide
      final response = await _httpClient.dio.get('/users/$uid');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
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
