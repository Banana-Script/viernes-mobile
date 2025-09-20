import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sse_events.dart';
import '../repositories/conversations_repository.dart';

class ListenToSSEEvents {
  final ConversationsRepository _repository;

  ListenToSSEEvents(this._repository);

  Stream<Either<Failure, SSEEvent>> call(
    int conversationId,
    String token,
  ) {
    return _repository.getConversationSSEStream(conversationId, token);
  }
}