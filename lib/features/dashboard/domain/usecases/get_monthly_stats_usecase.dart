import '../entities/monthly_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetMonthlyStatsUseCase {
  final DashboardRepository _repository;

  GetMonthlyStatsUseCase(this._repository);

  Future<MonthlyStats> call() async {
    return await _repository.getMonthlyStats();
  }
}