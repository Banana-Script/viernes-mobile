import '../entities/message_entity.dart';
import '../repositories/conversation_repository.dart';

/// Send Media Use Case
///
/// Uploads and sends a media/file message to a conversation.
class SendMediaUseCase {
  final ConversationRepository _repository;

  SendMediaUseCase(this._repository);

  /// Execute use case
  ///
  /// Parameters:
  /// - [conversationId]: The conversation ID
  /// - [filePath]: Local file path
  /// - [fileName]: File name
  /// - [caption]: Optional caption text
  ///
  /// Returns the created message entity
  Future<MessageEntity> call({
    required int conversationId,
    required String filePath,
    required String fileName,
    String? caption,
  }) async {
    // Validate file path
    if (filePath.trim().isEmpty) {
      throw ArgumentError('File path cannot be empty');
    }

    if (fileName.trim().isEmpty) {
      throw ArgumentError('File name cannot be empty');
    }

    return await _repository.sendMediaMessage(
      conversationId: conversationId,
      filePath: filePath,
      fileName: fileName,
      caption: caption,
    );
  }
}
