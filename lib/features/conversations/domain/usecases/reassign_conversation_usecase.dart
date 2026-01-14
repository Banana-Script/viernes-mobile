import '../repositories/conversation_repository.dart';

/// Reassign Conversation Use Case
///
/// Reassigns a conversation to a different agent.
/// Used when an agent requests to reassign a conversation to another team member.
class ReassignConversationUseCase {
  final ConversationRepository _repository;

  ReassignConversationUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID to reassign
  /// - [newAgentId]: The ID of the agent to reassign to
  ///
  /// Returns void on success
  Future<void> call({
    required int conversationId,
    required int newAgentId,
  }) async {
    return await _repository.reassignConversation(
      conversationId: conversationId,
      newAgentId: newAgentId,
    );
  }
}
