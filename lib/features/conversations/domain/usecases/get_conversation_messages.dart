import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_message.dart';
import '../repositories/conversations_repository.dart';

class GetConversationMessages {
  final ConversationsRepository _repository;

  GetConversationMessages(this._repository);

  Future<Either<Failure, ConversationMessagesResponse>> call(
    int conversationId,
  ) async {
    return await _repository.getConversationMessages(conversationId);
  }
}

class GetPreviousConversationMessages {
  final ConversationsRepository _repository;

  GetPreviousConversationMessages(this._repository);

  Future<Either<Failure, ConversationMessagesResponse>> call(
    int conversationId,
  ) async {
    return await _repository.getPreviousConversationMessages(conversationId);
  }
}