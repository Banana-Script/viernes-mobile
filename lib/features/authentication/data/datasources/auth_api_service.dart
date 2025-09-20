import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthApiService {
  Future<UserModel?> getUserByUid(String uid);
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });
  Future<UserModel> getCurrentUserOrganizationalInfo();
  Future<bool> getUserAvailabilityStatus(String databaseId);
  Future<void> toggleUserAvailability(String databaseId, bool available);
}

class AuthApiServiceImpl implements AuthApiService {
  final Dio _dio;

  AuthApiServiceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final response = await _dio.get('/users/by-uid/$uid');

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // User not found
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': '010', // Default role as per web app
        'status': '020', // Default status as per web app
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to register user',
    );
  }

  @override
  Future<UserModel> getCurrentUserOrganizationalInfo() async {
    final response = await _dio.get('/auth/current-user-organizational-info');

    if (response.statusCode == 200) {
      return UserModel.fromJson(response.data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to get organizational info',
    );
  }

  @override
  Future<bool> getUserAvailabilityStatus(String databaseId) async {
    final response = await _dio.get('/user-status/$databaseId');

    if (response.statusCode == 200) {
      return response.data['available'] ?? false;
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Failed to get user availability status',
    );
  }

  @override
  Future<void> toggleUserAvailability(String databaseId, bool available) async {
    final response = await _dio.post(
      '/user-status/$databaseId/toggle',
      data: {'available': available},
    );

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to toggle user availability',
      );
    }
  }
}