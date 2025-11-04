import '../repositories/conversation_repository.dart';

/// Assign Conversation Use Case
///
/// Assigns a conversation to one or more agents.
class AssignConversationUseCase {
  final ConversationRepository _repository;

  AssignConversationUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID
  /// - [agentIds]: List of agent IDs to assign
  ///
  /// Returns void on success
  Future<void> call({
    required int conversationId,
    required List<int> agentIds,
  }) async {
    if (agentIds.isEmpty) {
      throw ArgumentError('At least one agent ID must be provided');
    }

    return await _repository.assignConversation(
      conversationId: conversationId,
      agentIds: agentIds,
    );
  }
}
