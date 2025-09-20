import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../repositories/conversations_repository.dart';

class GetConversations {
  final ConversationsRepository _repository;

  GetConversations(this._repository);

  Future<Either<Failure, ConversationsResponse>> call(
    ConversationsParams params,
  ) async {
    return await _repository.getConversations(params);
  }
}

class GetAllConversations {
  final ConversationsRepository _repository;

  GetAllConversations(this._repository);

  Future<Either<Failure, ConversationsResponse>> call(
    ConversationsParams params,
  ) async {
    return await _repository.getAllConversations(params);
  }
}

class GetMyConversations {
  final ConversationsRepository _repository;

  GetMyConversations(this._repository);

  Future<Either<Failure, ConversationsResponse>> call(
    int agentId,
    ConversationsParams params,
  ) async {
    return await _repository.getMyConversations(agentId, params);
  }
}

class GetViernesConversations {
  final ConversationsRepository _repository;

  GetViernesConversations(this._repository);

  Future<Either<Failure, ConversationsResponse>> call(
    ConversationsParams params,
  ) async {
    return await _repository.getViernesConversations(params);
  }
}

class GetConversationById {
  final ConversationsRepository _repository;

  GetConversationById(this._repository);

  Future<Either<Failure, Conversation>> call(int conversationId) async {
    return await _repository.getConversationById(conversationId);
  }
}