import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

abstract class AuthApiService {
  Future<AuthResultModel> validateFirebaseToken(String firebaseToken);

  Future<AuthResultModel> refreshToken(String refreshToken);

  Future<UserModel> getCurrentUser();

  Future<UserModel> updateUserAvailability(bool isAvailable);

  Future<void> logout(String token);
}

class AuthApiServiceImpl implements AuthApiService {
  final DioClient _dioClient;

  AuthApiServiceImpl({required DioClient dioClient}) : _dioClient = dioClient;

  @override
  Future<AuthResultModel> validateFirebaseToken(String firebaseToken) async {
    try {
      final response = await _dioClient.post(
        '/auth/firebase/validate',
        data: {'firebase_token': firebaseToken},
      );

      if (response.statusCode == 200) {
        return AuthResultModel.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Token validation failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error during token validation: ${e.toString()}');
    }
  }

  @override
  Future<AuthResultModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return AuthResultModel.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error during token refresh: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get('/auth/me');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to get user data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error getting user data: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserAvailability(bool isAvailable) async {
    try {
      final response = await _dioClient.put(
        '/auth/availability',
        data: {'is_available': isAvailable},
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: 'Failed to update availability',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'Unexpected error updating availability: ${e.toString()}');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      final response = await _dioClient.post(
        '/auth/logout',
        data: {'token': token},
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Logout failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      // Don't throw error for logout - best effort
      print('Logout API call failed: ${e.toString()}');
    } catch (e) {
      // Don't throw error for logout - best effort
      print('Unexpected error during logout: ${e.toString()}');
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(message: 'Request timeout. Please try again.');

      case DioExceptionType.connectionError:
        return const ApiException(message: 'Connection error. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        switch (statusCode) {
          case 400:
            return ApiException(message: message ?? 'Invalid request', statusCode: statusCode);
          case 401:
            return ApiException(message: 'Authentication failed', statusCode: statusCode);
          case 403:
            return ApiException(message: 'Access denied', statusCode: statusCode);
          case 404:
            return ApiException(message: 'Resource not found', statusCode: statusCode);
          case 422:
            return ApiException(message: message ?? 'Validation failed', statusCode: statusCode);
          case 429:
            return ApiException(message: 'Too many requests. Please try again later.', statusCode: statusCode);
          case 500:
            return ApiException(message: 'Server error. Please try again later.', statusCode: statusCode);
          default:
            return ApiException(
              message: message ?? 'Request failed',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled');

      case DioExceptionType.unknown:
      default:
        return ApiException(message: 'Network error: ${error.message}');
    }
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try different common error message keys
      return responseData['message'] ??
          responseData['error'] ??
          responseData['detail'] ??
          responseData['msg'];
    }
    return null;
  }
}