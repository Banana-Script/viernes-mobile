import '../entities/message_entity.dart';
import '../repositories/conversation_repository.dart';

/// Send Message Use Case
///
/// Sends a text message to a conversation.
class SendMessageUseCase {
  final ConversationRepository _repository;

  SendMessageUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID
  /// - [text]: Message text content
  ///
  /// Returns the created message entity
  Future<MessageEntity> call({
    required int conversationId,
    required String text,
  }) async {
    // Validate message text
    if (text.trim().isEmpty) {
      throw ArgumentError('Message text cannot be empty');
    }

    if (text.length > 4096) {
      throw ArgumentError('Message text exceeds maximum length of 4096 characters');
    }

    return await _repository.sendMessage(
      conversationId: conversationId,
      text: text.trim(),
    );
  }
}
