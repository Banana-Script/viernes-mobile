import '../entities/ai_human_stats.dart';
import '../repositories/dashboard_repository.dart';

class GetAiHumanStatsUseCase {
  final DashboardRepository _repository;

  GetAiHumanStatsUseCase(this._repository);

  Future<AiHumanStats> call() async {
    return await _repository.getAiHumanStats();
  }
}