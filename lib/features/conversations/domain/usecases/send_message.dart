import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation_message.dart';
import '../repositories/conversations_repository.dart';

class SendMessage {
  final ConversationsRepository _repository;

  SendMessage(this._repository);

  Future<Either<Failure, SendMessageResponse>> call(
    SendMessageRequest request,
  ) async {
    return await _repository.sendMessage(request);
  }
}