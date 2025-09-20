import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/conversation_message.dart';
import '../entities/sse_events.dart';

abstract class ConversationsRepository {
  // Conversations
  Future<Either<Failure, ConversationsResponse>> getConversations(
    ConversationsParams params,
  );

  Future<Either<Failure, ConversationsResponse>> getAllConversations(
    ConversationsParams params,
  );

  Future<Either<Failure, ConversationsResponse>> getMyConversations(
    int agentId,
    ConversationsParams params,
  );

  Future<Either<Failure, ConversationsResponse>> getViernesConversations(
    ConversationsParams params,
  );

  Future<Either<Failure, Conversation>> getConversationById(int conversationId);

  // Messages
  Future<Either<Failure, ConversationMessagesResponse>> getConversationMessages(
    int conversationId,
  );

  Future<Either<Failure, ConversationMessagesResponse>> getPreviousConversationMessages(
    int conversationId,
  );

  Future<Either<Failure, SendMessageResponse>> sendMessage(
    SendMessageRequest request,
  );

  // Status and assignment
  Future<Either<Failure, void>> updateConversationStatus(
    int conversationId,
    int statusId,
    int organizationId,
  );

  Future<Either<Failure, Map<String, String>>> assignConversation(
    int conversationId,
    int agentId,
  );

  Future<Either<Failure, Map<String, String>>> assignConversationWithReopen(
    int conversationId,
    int agentId,
    bool reopen,
  );

  Future<Either<Failure, void>> reassignConversation(
    int conversationId,
    int newAgentId,
  );

  // SSE Events
  Stream<Either<Failure, SSEEvent>> getConversationSSEStream(
    int conversationId,
    String token,
  );

  // Utility
  Future<Either<Failure, bool>> checkUserAvailability(int userId);
}