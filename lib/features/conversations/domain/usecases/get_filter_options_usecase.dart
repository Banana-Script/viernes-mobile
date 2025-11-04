import '../repositories/conversation_repository.dart';

/// Get Filter Options Use Case
///
/// Fetches available filter options (statuses, tags, agents).
class GetFilterOptionsUseCase {
  final ConversationRepository _repository;

  GetFilterOptionsUseCase(this._repository);

  /// Get available statuses
  Future<List<ConversationStatusOption>> getStatuses() async {
    return await _repository.getStatuses();
  }

  /// Get available tags
  Future<List<TagOption>> getTags() async {
    return await _repository.getTags();
  }

  /// Get available agents
  Future<List<AgentOption>> getAgents() async {
    return await _repository.getAgents();
  }
}
