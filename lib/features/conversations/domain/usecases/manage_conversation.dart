import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/conversations_repository.dart';

class UpdateConversationStatus {
  final ConversationsRepository _repository;

  UpdateConversationStatus(this._repository);

  Future<Either<Failure, void>> call(
    int conversationId,
    int statusId,
    int organizationId,
  ) async {
    return await _repository.updateConversationStatus(
      conversationId,
      statusId,
      organizationId,
    );
  }
}

class AssignConversation {
  final ConversationsRepository _repository;

  AssignConversation(this._repository);

  Future<Either<Failure, Map<String, String>>> call(
    int conversationId,
    int agentId,
  ) async {
    return await _repository.assignConversation(conversationId, agentId);
  }
}

class AssignConversationWithReopen {
  final ConversationsRepository _repository;

  AssignConversationWithReopen(this._repository);

  Future<Either<Failure, Map<String, String>>> call(
    int conversationId,
    int agentId,
    bool reopen,
  ) async {
    return await _repository.assignConversationWithReopen(
      conversationId,
      agentId,
      reopen,
    );
  }
}

class ReassignConversation {
  final ConversationsRepository _repository;

  ReassignConversation(this._repository);

  Future<Either<Failure, void>> call(
    int conversationId,
    int newAgentId,
  ) async {
    return await _repository.reassignConversation(conversationId, newAgentId);
  }
}

class CheckUserAvailability {
  final ConversationsRepository _repository;

  CheckUserAvailability(this._repository);

  Future<Either<Failure, bool>> call(int userId) async {
    return await _repository.checkUserAvailability(userId);
  }
}