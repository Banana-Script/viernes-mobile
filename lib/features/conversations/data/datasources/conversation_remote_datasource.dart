import 'package:dio/dio.dart';
import '../../../../core/services/http_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/conversation_filters.dart';
import '../models/message_model.dart';
import '../models/conversations_list_response_model.dart';
import '../../../customers/data/models/conversation_model.dart';

/// Conversation Remote Data Source
///
/// Handles all HTTP requests related to conversations and messages.
abstract class ConversationRemoteDataSource {
  /// Get conversations list with pagination and filters
  Future<ConversationsListResponseModel> getConversations({
    required int page,
    required int pageSize,
    required ConversationFilters filters,
    String searchTerm = '',
    String orderBy = 'updated_at',
    String orderDirection = 'desc',
  });

  /// Get conversation by ID
  Future<ConversationModel> getConversationById(int conversationId);

  /// Get messages for a conversation
  Future<MessagesResponseModel> getMessages({
    required int conversationId,
    required int page,
    required int pageSize,
  });

  /// Send text message
  Future<MessageModel> sendMessage({
    required int conversationId,
    required String text,
  });

  /// Send media message
  Future<MessageModel> sendMediaMessage({
    required int conversationId,
    required String filePath,
    required String fileName,
    String? caption,
  });

  /// Update conversation status
  Future<void> updateConversationStatus({
    required int conversationId,
    required int statusId,
  });

  /// Update conversation priority
  Future<void> updateConversationPriority({
    required int conversationId,
    required String priority,
  });

  /// Assign conversation to agents
  Future<void> assignConversation({
    required int conversationId,
    required List<int> agentIds,
  });

  /// Add tags to conversation
  Future<void> addTags({
    required int conversationId,
    required List<int> tagIds,
  });

  /// Remove tags from conversation
  Future<void> removeTags({
    required int conversationId,
    required List<int> tagIds,
  });

  /// Mark conversation as read
  Future<void> markAsRead(int conversationId);

  /// Get available statuses
  Future<List<ConversationStatusOptionModel>> getStatuses();

  /// Get available tags
  Future<List<TagOptionModel>> getTags();

  /// Get available agents
  Future<List<AgentOptionModel>> getAgents();
}

/// Conversation Remote Data Source Implementation
class ConversationRemoteDataSourceImpl implements ConversationRemoteDataSource {
  final HttpClient _httpClient;

  ConversationRemoteDataSourceImpl(this._httpClient);

  @override
  Future<ConversationsListResponseModel> getConversations({
    required int page,
    required int pageSize,
    required ConversationFilters filters,
    String searchTerm = '',
    String orderBy = 'updated_at',
    String orderDirection = 'desc',
  }) async {
    const endpoint = '/conversations/';

    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
        'order_by': orderBy,
        'order_direction': orderDirection,
      };

      // Add search term if provided
      if (searchTerm.isNotEmpty) {
        queryParams['search_term'] = searchTerm;
      }

      // Add filters if any are active
      final filtersString = filters.toApiString();
      if (filtersString.isNotEmpty) {
        queryParams['filters'] = filtersString;
      }

      AppLogger.apiRequest('GET', endpoint, params: queryParams);

      final response = await _httpClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        return ConversationsListResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw NetworkException(
          'Failed to load conversations',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw TimeoutException(
          'Request timeout while fetching conversations',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching conversations',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing conversations response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<ConversationModel> getConversationById(int conversationId) async {
    final endpoint = '/conversations/$conversationId/';

    try {
      AppLogger.apiRequest('GET', endpoint);

      final response = await _httpClient.dio.get(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        return ConversationModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to load conversation',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Conversation not found',
          resourceType: 'Conversation',
          resourceId: conversationId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching conversation',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      if (e is NotFoundException) rethrow;
      throw ParseException(
        'Error parsing conversation response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<MessagesResponseModel> getMessages({
    required int conversationId,
    required int page,
    required int pageSize,
  }) async {
    const endpoint = '/conversation';

    try {
      final queryParams = {
        'conversationId': conversationId.toString(),
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      AppLogger.apiRequest('GET', endpoint, params: queryParams);

      final response = await _httpClient.dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        return MessagesResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to load messages',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 404) {
        // Return empty messages instead of throwing
        return const MessagesResponseModel(
          messages: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while fetching messages',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing messages response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<MessageModel> sendMessage({
    required int conversationId,
    required String text,
  }) async {
    final endpoint = '/conversations/$conversationId/messages/';

    try {
      final requestData = {
        'text': text,
        'type': 'text',
      };

      AppLogger.apiRequest('POST', endpoint, params: requestData);

      final response = await _httpClient.dio.post(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to send message',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid message data',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Conversation not found',
          resourceType: 'Conversation',
          resourceId: conversationId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while sending message',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing send message response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<MessageModel> sendMediaMessage({
    required int conversationId,
    required String filePath,
    required String fileName,
    String? caption,
  }) async {
    final endpoint = '/conversations/$conversationId/messages/media/';

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        if (caption != null && caption.isNotEmpty) 'caption': caption,
      });

      AppLogger.apiRequest('POST', endpoint, params: {'file': fileName});

      final response = await _httpClient.dio.post(
        endpoint,
        data: formData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NetworkException(
          'Failed to send media message',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid file or file too large',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Conversation not found',
          resourceType: 'Conversation',
          resourceId: conversationId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while sending media',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing send media response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<void> updateConversationStatus({
    required int conversationId,
    required int statusId,
  }) async {
    final endpoint = '/conversations/$conversationId/';

    try {
      final requestData = {
        'status_id': statusId,
      };

      AppLogger.apiRequest('PATCH', endpoint, params: requestData);

      final response = await _httpClient.dio.patch(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200) {
        throw NetworkException(
          'Failed to update conversation status',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);

      if (e.response?.statusCode == 404) {
        throw NotFoundException(
          'Conversation not found',
          resourceType: 'Conversation',
          resourceId: conversationId,
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          'Invalid status ID',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          'Authentication required',
          stackTrace: stackTrace,
          originalError: e,
        );
      } else {
        throw NetworkException(
          'Network error while updating status',
          statusCode: e.response?.statusCode,
          endpoint: endpoint,
          stackTrace: stackTrace,
          originalError: e,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      if (e is NotFoundException || e is ValidationException || e is UnauthorizedException) {
        rethrow;
      }
      throw NetworkException(
        'Error updating conversation status: ${e.toString()}',
        endpoint: endpoint,
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
    final endpoint = '/conversations/$conversationId/';

    try {
      final requestData = {
        'priority': priority,
      };

      AppLogger.apiRequest('PATCH', endpoint, params: requestData);

      final response = await _httpClient.dio.patch(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200) {
        throw NetworkException(
          'Failed to update conversation priority',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      _handleDioException(e, stackTrace, endpoint, conversationId);
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      _handleGenericException(e, stackTrace, endpoint);
    }
  }

  @override
  Future<void> assignConversation({
    required int conversationId,
    required List<int> agentIds,
  }) async {
    final endpoint = '/conversations/$conversationId/assign/';

    try {
      final requestData = {
        'agent_ids': agentIds,
      };

      AppLogger.apiRequest('POST', endpoint, params: requestData);

      final response = await _httpClient.dio.post(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw NetworkException(
          'Failed to assign conversation',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      _handleDioException(e, stackTrace, endpoint, conversationId);
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      _handleGenericException(e, stackTrace, endpoint);
    }
  }

  @override
  Future<void> addTags({
    required int conversationId,
    required List<int> tagIds,
  }) async {
    final endpoint = '/conversations/$conversationId/tags/';

    try {
      final requestData = {
        'tag_ids': tagIds,
      };

      AppLogger.apiRequest('POST', endpoint, params: requestData);

      final response = await _httpClient.dio.post(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw NetworkException(
          'Failed to add tags',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      _handleDioException(e, stackTrace, endpoint, conversationId);
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      _handleGenericException(e, stackTrace, endpoint);
    }
  }

  @override
  Future<void> removeTags({
    required int conversationId,
    required List<int> tagIds,
  }) async {
    final endpoint = '/conversations/$conversationId/tags/';

    try {
      final requestData = {
        'tag_ids': tagIds,
      };

      AppLogger.apiRequest('DELETE', endpoint, params: requestData);

      final response = await _httpClient.dio.delete(
        endpoint,
        data: requestData,
      );

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw NetworkException(
          'Failed to remove tags',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      _handleDioException(e, stackTrace, endpoint, conversationId);
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      _handleGenericException(e, stackTrace, endpoint);
    }
  }

  @override
  Future<void> markAsRead(int conversationId) async {
    final endpoint = '/conversations/$conversationId/read/';

    try {
      AppLogger.apiRequest('POST', endpoint);

      final response = await _httpClient.dio.post(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw NetworkException(
          'Failed to mark as read',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      _handleDioException(e, stackTrace, endpoint, conversationId);
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      _handleGenericException(e, stackTrace, endpoint);
    }
  }

  @override
  Future<List<ConversationStatusOptionModel>> getStatuses() async {
    const endpoint = '/conversation_statuses/';

    try {
      AppLogger.apiRequest('GET', endpoint);

      final response = await _httpClient.dio.get(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['data'] as List?)
                ?.map((s) => ConversationStatusOptionModel.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [];
      } else {
        throw NetworkException(
          'Failed to load statuses',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      throw NetworkException(
        'Network error while fetching statuses',
        statusCode: e.response?.statusCode,
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing statuses response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<TagOptionModel>> getTags() async {
    const endpoint = '/organizations/organization_tags/';

    try {
      AppLogger.apiRequest('GET', endpoint);

      final response = await _httpClient.dio.get(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['data'] as List?)
                ?.map((t) => TagOptionModel.fromJson(t as Map<String, dynamic>))
                .toList() ??
            [];
      } else {
        throw NetworkException(
          'Failed to load tags',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      throw NetworkException(
        'Network error while fetching tags',
        statusCode: e.response?.statusCode,
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing tags response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  @override
  Future<List<AgentOptionModel>> getAgents() async {
    const endpoint = '/organization_users/agents/';

    try {
      AppLogger.apiRequest('GET', endpoint);

      final response = await _httpClient.dio.get(endpoint);

      AppLogger.apiResponse(response.statusCode ?? 0, endpoint);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return (data['data'] as List?)
                ?.map((a) => AgentOptionModel.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [];
      } else {
        throw NetworkException(
          'Failed to load agents',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace, statusCode: e.response?.statusCode);
      throw NetworkException(
        'Network error while fetching agents',
        statusCode: e.response?.statusCode,
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    } catch (e, stackTrace) {
      AppLogger.apiError(endpoint, e, stackTrace);
      throw ParseException(
        'Error parsing agents response: ${e.toString()}',
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  // Helper methods for error handling
  void _handleDioException(
    DioException e,
    StackTrace stackTrace,
    String endpoint,
    int? resourceId,
  ) {
    if (e.response?.statusCode == 404) {
      throw NotFoundException(
        'Resource not found',
        resourceType: 'Conversation',
        resourceId: resourceId,
        stackTrace: stackTrace,
        originalError: e,
      );
    } else if (e.response?.statusCode == 400) {
      throw ValidationException(
        'Invalid request data',
        stackTrace: stackTrace,
        originalError: e,
      );
    } else if (e.response?.statusCode == 401) {
      throw UnauthorizedException(
        'Authentication required',
        stackTrace: stackTrace,
        originalError: e,
      );
    } else {
      throw NetworkException(
        'Network error',
        statusCode: e.response?.statusCode,
        endpoint: endpoint,
        stackTrace: stackTrace,
        originalError: e,
      );
    }
  }

  void _handleGenericException(
    Object e,
    StackTrace stackTrace,
    String endpoint,
  ) {
    if (e is NotFoundException ||
        e is ValidationException ||
        e is UnauthorizedException) {
      throw e;
    }
    throw NetworkException(
      'Error processing request: ${e.toString()}',
      endpoint: endpoint,
      stackTrace: stackTrace,
      originalError: e,
    );
  }
}
