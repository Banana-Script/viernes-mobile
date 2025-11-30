import '../repositories/conversation_repository.dart';
import '../../../customers/domain/entities/conversation_entity.dart';

/// Get Conversation Detail Use Case
///
/// Fetches a single conversation with full details.
class GetConversationDetailUseCase {
  final ConversationRepository _repository;

  GetConversationDetailUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID
  ///
  /// Returns conversation entity
  Future<ConversationEntity> call(int conversationId) async {
    return await _repository.getConversationById(conversationId);
  }
}
