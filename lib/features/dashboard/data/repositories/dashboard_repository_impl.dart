import '../../domain/entities/monthly_stats.dart';
import '../../domain/entities/ai_human_stats.dart';
import '../../domain/entities/customer_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<MonthlyStats> getMonthlyStats() async {
    try {
      final model = await _remoteDataSource.getMonthlyStats();
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get monthly stats: $e');
    }
  }

  @override
  Future<AiHumanStats> getAiHumanStats() async {
    try {
      final model = await _remoteDataSource.getAiHumanStats();
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get AI vs Human stats: $e');
    }
  }

  @override
  Future<CustomerSummary> getCustomerSummary() async {
    try {
      final model = await _remoteDataSource.getCustomerSummary();
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get customer summary: $e');
    }
  }

  @override
  Future<String> exportConversationStats() async {
    try {
      return await _remoteDataSource.exportConversationStats();
    } catch (e) {
      throw Exception('Failed to export conversation stats: $e');
    }
  }
}