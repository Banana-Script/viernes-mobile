import '../repositories/conversation_repository.dart';

/// Update Conversation Status Use Case
///
/// Updates the status of a conversation.
class UpdateConversationStatusUseCase {
  final ConversationRepository _repository;

  UpdateConversationStatusUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID
  /// - [statusId]: New status ID
  /// - [organizationId]: The organization ID
  ///
  /// Returns void on success
  Future<void> call({
    required int conversationId,
    required int statusId,
    required int organizationId,
  }) async {
    return await _repository.updateConversationStatus(
      conversationId: conversationId,
      statusId: statusId,
      organizationId: organizationId,
    );
  }
}
