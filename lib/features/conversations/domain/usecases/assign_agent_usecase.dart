import '../repositories/conversation_repository.dart';

/// Assign Agent Use Case
///
/// Assigns a single agent to a conversation (self-assignment).
/// Uses the dedicated /assign_agent endpoint.
class AssignAgentUseCase {
  final ConversationRepository _repository;

  AssignAgentUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID
  /// - [userId]: The user/agent ID to assign
  /// - [reopen]: Whether to reopen the conversation if closed
  ///
  /// Returns void on success
  Future<void> call({
    required int conversationId,
    required int userId,
    bool reopen = false,
  }) async {
    return await _repository.assignAgent(
      conversationId: conversationId,
      userId: userId,
      reopen: reopen,
    );
  }
}
