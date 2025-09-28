import '../repositories/dashboard_repository.dart';

class ExportConversationStatsUseCase {
  final DashboardRepository _repository;

  ExportConversationStatsUseCase(this._repository);

  Future<String> call() async {
    return await _repository.exportConversationStats();
  }
}