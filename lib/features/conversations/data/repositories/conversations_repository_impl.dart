import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/conversation_message.dart';
import '../../domain/entities/sse_events.dart';
import '../../domain/repositories/conversations_repository.dart';
import '../datasources/conversations_remote_data_source.dart';
import '../datasources/conversations_sse_data_source.dart';
import '../models/conversation_model.dart';
import '../models/conversation_message_model.dart';

class ConversationsRepositoryImpl implements ConversationsRepository {
  final ConversationsRemoteDataSource _remoteDataSource;
  final ConversationsSSEDataSource _sseDataSource;

  ConversationsRepositoryImpl(
    this._remoteDataSource,
    this._sseDataSource,
  );

  @override
  Future<Either<Failure, ConversationsResponse>> getConversations(
    ConversationsParams params,
  ) async {
    try {
      final paramsModel = ConversationsParamsModel.fromDomain(params);
      final result = await _remoteDataSource.getConversations(paramsModel);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationsResponse>> getAllConversations(
    ConversationsParams params,
  ) async {
    try {
      final paramsModel = ConversationsParamsModel.fromDomain(params);
      final result = await _remoteDataSource.getAllConversations(paramsModel);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationsResponse>> getMyConversations(
    int agentId,
    ConversationsParams params,
  ) async {
    try {
      final paramsModel = ConversationsParamsModel.fromDomain(params);
      final result = await _remoteDataSource.getMyConversations(agentId, paramsModel);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationsResponse>> getViernesConversations(
    ConversationsParams params,
  ) async {
    try {
      final paramsModel = ConversationsParamsModel.fromDomain(params);
      final result = await _remoteDataSource.getViernesConversations(paramsModel);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversationById(int conversationId) async {
    try {
      final result = await _remoteDataSource.getConversationById(conversationId);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationMessagesResponse>> getConversationMessages(
    int conversationId,
  ) async {
    try {
      final result = await _remoteDataSource.getConversationMessages(conversationId);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationMessagesResponse>> getPreviousConversationMessages(
    int conversationId,
  ) async {
    try {
      final result = await _remoteDataSource.getPreviousConversationMessages(conversationId);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendMessageResponse>> sendMessage(
    SendMessageRequest request,
  ) async {
    try {
      final requestModel = SendMessageRequestModel.fromDomain(request);
      final result = await _remoteDataSource.sendMessage(requestModel);
      return Right(result.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateConversationStatus(
    int conversationId,
    int statusId,
    int organizationId,
  ) async {
    try {
      await _remoteDataSource.updateConversationStatus(
        conversationId,
        statusId,
        organizationId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> assignConversation(
    int conversationId,
    int agentId,
  ) async {
    try {
      final result = await _remoteDataSource.assignConversation(conversationId, agentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> assignConversationWithReopen(
    int conversationId,
    int agentId,
    bool reopen,
  ) async {
    try {
      final result = await _remoteDataSource.assignConversationWithReopen(
        conversationId,
        agentId,
        reopen,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reassignConversation(
    int conversationId,
    int newAgentId,
  ) async {
    try {
      await _remoteDataSource.reassignConversation(conversationId, newAgentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, SSEEvent>> getConversationSSEStream(
    int conversationId,
    String token,
  ) async* {
    try {
      await for (final eventModel in _sseDataSource.getConversationSSEStream(
        conversationId,
        token,
      )) {
        yield Right(eventModel.toDomain());
      }
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message));
    } catch (e) {
      yield Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserAvailability(int userId) async {
    try {
      final result = await _remoteDataSource.checkUserAvailability(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}