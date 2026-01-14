import '../repositories/conversation_repository.dart';

/// Get Organization Agents Use Case
///
/// Retrieves the list of organization agents for reassignment.
/// Returns all agents that a conversation can be reassigned to.
class GetOrganizationAgentsUseCase {
  final ConversationRepository _repository;

  GetOrganizationAgentsUseCase(this._repository);

  /// Execute use case
  ///
  /// Returns list of agents available for reassignment
  Future<List<AgentOption>> call() async {
    return await _repository.getOrganizationAgents();
  }
}
