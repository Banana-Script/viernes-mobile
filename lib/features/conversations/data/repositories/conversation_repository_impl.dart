import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/conversation_filters.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../../customers/domain/entities/conversation_entity.dart';
import '../datasources/conversation_remote_datasource.dart';

/// Conversation Repository Implementation
///
/// Implements the conversation repository interface using the remote data source.
/// Preserves custom exceptions from the datasource layer for proper error handling.
class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationRemoteDataSource _remoteDataSource;

  ConversationRepositoryImpl(this._remoteDataSource);

  @override
  Future<ConversationsListResponse> getConversations({
    required int page,
    required int pageSize,
    required ConversationFilters filters,
    String searchTerm = '',
    String orderBy = 'updated_at',
    String orderDirection = 'desc',
  }) async {
    try {
      final response = await _remoteDataSource.getConversations(
        page: page,
        pageSize: pageSize,
        filters: filters,
        searchTerm: searchTerm,
        orderBy: orderBy,
        orderDirection: orderDirection,
      );

      return ConversationsListResponse(
        conversations: response.conversations,
        totalCount: response.totalCount,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
      );
    } catch (e, stackTrace) {
      // Re-throw custom exceptions to preserve error information
      if (e is ViernesException) {
        rethrow;
      }

      // Wrap unknown exceptions
      throw NetworkException(
        'Failed to get conversations: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<ConversationEntity> getConversationById(int conversationId) async {
    try {
      return await _remoteDataSource.getConversationById(conversationId);
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get conversation: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<MessagesResponse> getMessages({
    required int conversationId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _remoteDataSource.getMessages(
        conversationId: conversationId,
        page: page,
        pageSize: pageSize,
      );

      return MessagesResponse(
        messages: response.messages,
        totalCount: response.totalCount,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        hasNextPage: response.hasNextPage,
        hasPreviousPage: response.hasPreviousPage,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get messages: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<MessageEntity> sendMessage({
    required int conversationId,
    required String sessionId,
    required String text,
  }) async {
    try {
      return await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        sessionId: sessionId,
        text: text,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to send message: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<MessageEntity> sendMediaMessage({
    required int conversationId,
    required String filePath,
    required String fileName,
    String? caption,
  }) async {
    try {
      return await _remoteDataSource.sendMediaMessage(
        conversationId: conversationId,
        filePath: filePath,
        fileName: fileName,
        caption: caption,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to send media: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateConversationStatus({
    required int conversationId,
    required int statusId,
    required int organizationId,
  }) async {
    try {
      await _remoteDataSource.updateConversationStatus(
        conversationId: conversationId,
        statusId: statusId,
        organizationId: organizationId,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to update status: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateConversationPriority({
    required int conversationId,
    required String priority,
  }) async {
    try {
      await _remoteDataSource.updateConversationPriority(
        conversationId: conversationId,
        priority: priority,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to update priority: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> assignConversation({
    required int conversationId,
    required List<int> agentIds,
  }) async {
    try {
      await _remoteDataSource.assignConversation(
        conversationId: conversationId,
        agentIds: agentIds,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to assign conversation: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> addTags({
    required int conversationId,
    required List<int> tagIds,
  }) async {
    try {
      await _remoteDataSource.addTags(
        conversationId: conversationId,
        tagIds: tagIds,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to add tags: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> removeTags({
    required int conversationId,
    required List<int> tagIds,
  }) async {
    try {
      await _remoteDataSource.removeTags(
        conversationId: conversationId,
        tagIds: tagIds,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to remove tags: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> markAsRead(int conversationId) async {
    try {
      await _remoteDataSource.markAsRead(conversationId);
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to mark as read: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<ConversationStatusOption>> getStatuses() async {
    try {
      return await _remoteDataSource.getStatuses();
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get statuses: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<TagOption>> getTags() async {
    try {
      return await _remoteDataSource.getTags();
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get tags: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<AgentOption>> getAgents() async {
    try {
      return await _remoteDataSource.getAgents();
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to get agents: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> assignAgent({
    required int conversationId,
    required int userId,
    bool reopen = false,
  }) async {
    try {
      await _remoteDataSource.assignAgent(
        conversationId: conversationId,
        userId: userId,
        reopen: reopen,
      );
    } catch (e, stackTrace) {
      if (e is ViernesException) {
        rethrow;
      }

      throw NetworkException(
        'Failed to assign agent: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }
}
