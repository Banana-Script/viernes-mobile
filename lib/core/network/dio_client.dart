import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
// import 'package:dio_retry_interceptor/dio_retry_interceptor.dart'; // Will add later
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/environment.dart';
import '../errors/exceptions.dart';

/// HTTP client using Dio with interceptors for authentication, caching, and retry logic
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage {
    _dio = Dio(_buildBaseOptions());
    _setupInterceptors();
  }

  /// Get the Dio instance
  Dio get dio => _dio;

  /// Build base options for Dio
  BaseOptions _buildBaseOptions() {
    final config = AppConfig.instance;
    return BaseOptions(
      baseUrl: config.fullApiUrl,
      connectTimeout: config.apiTimeout,
      receiveTimeout: config.apiTimeout,
      sendTimeout: config.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Accept all status codes to handle them manually
        return status != null && status < 500;
      },
    );
  }

  /// Setup interceptors for authentication, caching, retry, and logging
  void _setupInterceptors() {
    // Request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Cache interceptor
    _dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.request,
          hitCacheOnErrorExcept: [401, 403],
          maxStale: const Duration(days: 7),
        ),
      ),
    );

    // TODO: Add retry interceptor when package is available
    // _dio.interceptors.add(
    //   RetryInterceptor(
    //     dio: _dio,
    //     logPrint: AppConfig.instance.enableLogging ? print : null,
    //     retries: 3,
    //     retryDelays: const [
    //       Duration(seconds: 1),
    //       Duration(seconds: 2),
    //       Duration(seconds: 3),
    //     ],
    //   ),
    // );

    // Logging interceptor (development only)
    if (AppConfig.instance.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),
      );
    }
  }

  /// Handle request interceptor
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add authentication token if available
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  /// Handle response interceptor
  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Handle successful responses
    if (response.statusCode != null && response.statusCode! < 300) {
      handler.next(response);
      return;
    }

    // Handle error responses
    final error = DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
    handler.reject(error);
  }

  /// Handle error interceptor
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 unauthorized - attempt token refresh
    if (err.response?.statusCode == 401) {
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        // Retry the original request
        final options = err.requestOptions;
        final token = await _secureStorage.read(key: StorageKeys.accessToken);
        options.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await _dio.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // If retry fails, continue with original error
        }
      }
    }

    handler.next(err);
  }

  /// Attempt to refresh the authentication token
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        Endpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Don't include old token
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _secureStorage.write(
          key: StorageKeys.accessToken,
          value: data['access_token'],
        );
        if (data['refresh_token'] != null) {
          await _secureStorage.write(
            key: StorageKeys.refreshToken,
            value: data['refresh_token'],
          );
        }
        return true;
      }
    } catch (e) {
      // Clear tokens on refresh failure
      await _clearTokens();
    }
    return false;
  }

  /// Clear stored authentication tokens
  Future<void> _clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: StorageKeys.accessToken),
      _secureStorage.delete(key: StorageKeys.refreshToken),
    ]);
  }

  /// GET request wrapper
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// POST request wrapper
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PUT request wrapper
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// DELETE request wrapper
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// PATCH request wrapper
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Map Dio exceptions to application exceptions
  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timeout',
          code: 'TIMEOUT',
          originalException: e,
          timeout: AppConfig.instance.apiTimeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _getErrorMessage(e.response?.data);

        if (statusCode == 401) {
          return AuthException(
            message: message ?? 'Authentication failed',
            code: 'UNAUTHORIZED',
            originalException: e,
          );
        }

        if (statusCode == 403) {
          return AuthException(
            message: message ?? 'Access denied',
            code: 'FORBIDDEN',
            originalException: e,
          );
        }

        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return ValidationException(
            message: message ?? 'Client error',
            code: 'CLIENT_ERROR',
            originalException: e,
          );
        }

        return ServerException(
          message: message ?? 'Server error',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
          originalException: e,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Network connection failed',
          code: 'CONNECTION_ERROR',
          originalException: e,
        );

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled',
          code: 'REQUEST_CANCELLED',
          originalException: e,
        );

      case DioExceptionType.unknown:
        return NetworkException(
          message: 'Unknown network error',
          code: 'UNKNOWN',
          originalException: e,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Bad certificate',
          code: 'BAD_CERTIFICATE',
          originalException: e,
        );
    }
  }

  /// Extract error message from response data
  String? _getErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['detail'];
    }
    if (data is String) {
      return data;
    }
    return null;
  }

  /// Close the Dio client
  void close() {
    _dio.close();
  }
}