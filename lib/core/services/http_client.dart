import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/environment_config.dart';
import '../utils/logger.dart';

class HttpClient {
  static HttpClient? _instance;
  late Dio _dio;

  HttpClient._internal() {
    _dio = Dio();
    _setupInterceptors();
  }

  factory HttpClient() {
    _instance ??= HttpClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.options.baseUrl = EnvironmentConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Firebase ID token as Bearer token
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final idToken = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $idToken';
            } catch (e) {
              // Handle token refresh error
              AppLogger.error('Error getting Firebase ID token: $e', tag: 'HttpClient');
            }
          }

          // Add content type
          options.headers['Content-Type'] = 'application/json';

          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors by refreshing the token
          if (error.response?.statusCode == 401) {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              try {
                // Force refresh the token
                await user.getIdToken(true);

                // Retry the request
                final options = error.requestOptions;
                final idToken = await user.getIdToken();
                options.headers['Authorization'] = 'Bearer $idToken';

                final response = await _dio.request(
                  options.path,
                  options: Options(
                    method: options.method,
                    headers: options.headers,
                  ),
                  data: options.data,
                  queryParameters: options.queryParameters,
                );

                handler.resolve(response);
                return;
              } catch (e) {
                AppLogger.error('Error refreshing Firebase ID token: $e', tag: 'HttpClient');
              }
            }
          }

          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debug mode
    if (EnvironmentConfig.enableVerboseLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }
}
