import '../entities/message_entity.dart';
import '../repositories/conversation_repository.dart';

/// Get Messages Use Case
///
/// Fetches messages for a conversation with pagination.
class GetMessagesUseCase {
  final ConversationRepository _repository;

  GetMessagesUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID
  /// - [page]: Page number (default: 1)
  /// - [pageSize]: Number of messages per page (default: 50)
  ///
  /// Returns paginated messages response
  Future<MessagesResponse> call({
    required int conversationId,
    int page = 1,
    int pageSize = 50,
  }) async {
    return await _repository.getMessages(
      conversationId: conversationId,
      page: page,
      pageSize: pageSize,
    );
  }
}
