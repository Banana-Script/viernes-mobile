import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/conversation_message_model.dart';

abstract class ConversationsRemoteDataSource {
  Future<ConversationsResponseModel> getConversations(
    ConversationsParamsModel params,
  );

  Future<ConversationsResponseModel> getAllConversations(
    ConversationsParamsModel params,
  );

  Future<ConversationsResponseModel> getMyConversations(
    int agentId,
    ConversationsParamsModel params,
  );

  Future<ConversationsResponseModel> getViernesConversations(
    ConversationsParamsModel params,
  );

  Future<ConversationModel> getConversationById(int conversationId);

  Future<ConversationMessagesResponseModel> getConversationMessages(
    int conversationId,
  );

  Future<ConversationMessagesResponseModel> getPreviousConversationMessages(
    int conversationId,
  );

  Future<SendMessageResponseModel> sendMessage(
    SendMessageRequestModel request,
  );

  Future<void> updateConversationStatus(
    int conversationId,
    int statusId,
    int organizationId,
  );

  Future<Map<String, String>> assignConversation(
    int conversationId,
    int agentId,
  );

  Future<Map<String, String>> assignConversationWithReopen(
    int conversationId,
    int agentId,
    bool reopen,
  );

  Future<void> reassignConversation(
    int conversationId,
    int newAgentId,
  );

  Future<bool> checkUserAvailability(int userId);
}

class ConversationsRemoteDataSourceImpl implements ConversationsRemoteDataSource {
  final DioClient _dioClient;

  ConversationsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ConversationsResponseModel> getConversations(
    ConversationsParamsModel params,
  ) async {
    try {
      final queryParams = <String, dynamic>{
        'page': params.page,
        'page_size': params.pageSize,
        'order_by': params.orderBy,
        'order_direction': params.orderDirection,
        'search_term': params.searchTerm,
        'filters': params.filters,
        'conversation_type': params.conversationType,
      };

      final response = await _dioClient.dio.get(
        '/conversations/',
        queryParameters: queryParams,
      );

      return ConversationsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<ConversationsResponseModel> getAllConversations(
    ConversationsParamsModel params,
  ) async {
    return getConversations(params);
  }

  @override
  Future<ConversationsResponseModel> getMyConversations(
    int agentId,
    ConversationsParamsModel params,
  ) async {
    final baseFilter = '[agent_id=$agentId]';
    final mergedFilters = _mergeFilters(baseFilter, params.filters);
    final updatedParams = params.copyWith(filters: mergedFilters);
    return getConversations(updatedParams);
  }

  @override
  Future<ConversationsResponseModel> getViernesConversations(
    ConversationsParamsModel params,
  ) async {
    const baseFilter = '[agent_id=null|-1]';
    final mergedFilters = _mergeFilters(baseFilter, params.filters);
    final updatedParams = params.copyWith(filters: mergedFilters);
    return getConversations(updatedParams);
  }

  @override
  Future<ConversationModel> getConversationById(int conversationId) async {
    try {
      final response = await _dioClient.dio.get('/conversations/$conversationId');
      return ConversationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<ConversationMessagesResponseModel> getConversationMessages(
    int conversationId,
  ) async {
    try {
      final response = await _dioClient.dio.get(
        '/conversation',
        queryParameters: {'conversationId': conversationId},
      );
      return ConversationMessagesResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<ConversationMessagesResponseModel> getPreviousConversationMessages(
    int conversationId,
  ) async {
    try {
      final response = await _dioClient.dio.get(
        '/conversations/previous_conversation/$conversationId',
      );
      return ConversationMessagesResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<SendMessageResponseModel> sendMessage(
    SendMessageRequestModel request,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '/whatsapp-send-message',
        data: request.toJson(),
      );
      return SendMessageResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> updateConversationStatus(
    int conversationId,
    int statusId,
    int organizationId,
  ) async {
    try {
      await _dioClient.dio.patch(
        '/conversations/$conversationId',
        data: {
          'status_id': statusId,
          'organization_id': organizationId,
        },
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<Map<String, String>> assignConversation(
    int conversationId,
    int agentId,
  ) async {
    try {
      final queryParams = <String, String>{
        'conversation_id': conversationId.toString(),
        'user_id': agentId.toString(),
        'reopen': '0',
      };

      final response = await _dioClient.dio.post(
        '/assign_agent',
        queryParameters: queryParams,
      );

      return Map<String, String>.from(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<Map<String, String>> assignConversationWithReopen(
    int conversationId,
    int agentId,
    bool reopen,
  ) async {
    try {
      final queryParams = <String, String>{
        'conversation_id': conversationId.toString(),
        'user_id': agentId.toString(),
        'reopen': reopen ? '1' : '0',
      };

      final response = await _dioClient.dio.post(
        '/assign_agent',
        queryParameters: queryParams,
      );

      return Map<String, String>.from(response.data);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> reassignConversation(
    int conversationId,
    int newAgentId,
  ) async {
    try {
      await _dioClient.dio.post(
        '/conversations/reassign-agent/$conversationId/$newAgentId/',
        data: {},
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  @override
  Future<bool> checkUserAvailability(int userId) async {
    try {
      final response = await _dioClient.dio.get('/organization_users/read/$userId');
      return response.data != null;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Unknown error');
    }
  }

  String _mergeFilters(String baseFilter, String userFilter) {
    if (userFilter.isEmpty) {
      return baseFilter;
    }

    // Remove the brackets from both filters
    final baseFilterContent = baseFilter.substring(1, baseFilter.length - 1);
    final userFilterContent = userFilter.substring(1, userFilter.length - 1);

    // Combine and wrap in brackets
    return '[$baseFilterContent,$userFilterContent]';
  }
}