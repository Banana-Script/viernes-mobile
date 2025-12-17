import '../../../../core/errors/exceptions.dart';
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
  /// - [sessionId]: The WhatsApp session ID (phone number)
  /// - [text]: Message text content
  ///
  /// Returns the created message entity
  Future<MessageEntity> call({
    required int conversationId,
    required String sessionId,
    required String text,
  }) async {
    // Normalize inputs
    final normalizedSessionId = sessionId.trim();
    final normalizedText = text.trim();

    // Validate sessionId
    if (normalizedSessionId.isEmpty) {
      throw ValidationException(
        'Session ID cannot be empty',
        stackTrace: StackTrace.current,
      );
    }

    // Validate message text
    if (normalizedText.isEmpty) {
      throw ValidationException(
        'Message text cannot be empty',
        stackTrace: StackTrace.current,
      );
    }

    if (normalizedText.length > 4096) {
      throw ValidationException(
        'Message text exceeds maximum length of 4096 characters',
        stackTrace: StackTrace.current,
      );
    }

    return await _repository.sendMessage(
      conversationId: conversationId,
      sessionId: normalizedSessionId,
      text: normalizedText,
    );
  }
}
