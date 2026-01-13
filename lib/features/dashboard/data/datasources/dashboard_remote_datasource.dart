import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../../core/services/http_client.dart';
import '../models/monthly_stats_model.dart';
import '../models/ai_human_stats_model.dart';
import '../models/customer_summary_model.dart';

abstract class DashboardRemoteDataSource {
  Future<MonthlyStatsModel> getMonthlyStats();
  Future<AiHumanStatsModel> getAiHumanStats();
  Future<CustomerSummaryModel> getCustomerSummary();
  Future<String> exportConversationStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final HttpClient _httpClient;

  DashboardRemoteDataSourceImpl({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  @override
  Future<MonthlyStatsModel> getMonthlyStats() async {
    try {
      final response = await _httpClient.dio.get('/conversations/get-monthly-stats/');

      if (response.statusCode == 200) {
        return MonthlyStatsModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch monthly stats',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch monthly stats');
    } catch (e) {
      throw Exception('Unexpected error occurred while fetching monthly stats: $e');
    }
  }

  @override
  Future<AiHumanStatsModel> getAiHumanStats() async {
    try {
      final response = await _httpClient.dio.get('/analytics/ai-vs-human-stats');

      if (response.statusCode == 200) {
        return AiHumanStatsModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch AI vs Human stats',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch AI vs Human stats');
    } catch (e) {
      throw Exception('Unexpected error occurred while fetching AI vs Human stats: $e');
    }
  }

  @override
  Future<CustomerSummaryModel> getCustomerSummary() async {
    try {
      final response = await _httpClient.dio.get('/organization_users/customers/summary');

      if (response.statusCode == 200) {
        return CustomerSummaryModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch customer summary',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch customer summary');
    } catch (e) {
      throw Exception('Unexpected error occurred while fetching customer summary: $e');
    }
  }

  @override
  Future<String> exportConversationStats() async {
    try {
      final response = await _httpClient.dio.get(
        '/conversations/export-conversation-stats/',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        // Decode bytes to UTF-8 string for CSV content
        return utf8.decode(response.data as List<int>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to export conversation stats',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to export conversation stats');
    } catch (e) {
      throw Exception('Unexpected error occurred while exporting conversation stats: $e');
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
            return Exception('The requested resource was not found.');
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