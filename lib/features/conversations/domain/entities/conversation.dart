import 'package:freezed_annotation/freezed_annotation.dart';
import 'conversation_user.dart';
import 'conversation_agent.dart';
import 'conversation_status.dart';
import 'conversation_tag.dart';
import 'conversation_assign.dart';
import 'conversation_integration.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required int id,
    required int userId,
    required ConversationUser user,
    ConversationAgent? agent,
    required ConversationStatus status,
    @Default([]) List<ConversationTag> tags,
    ConversationAssign? assigns,
    required int organizationId,
    required int statusId,
    int? agentId,
    required String priority,
    required String category,
    required String sentiment,
    required String type,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? firstResponseAt,
    int? integrationId,
    ConversationIntegration? integration,
    required bool readed,
    required bool locked,
    String? memory,
    required int unreaded,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class ConversationsResponse with _$ConversationsResponse {
  const factory ConversationsResponse({
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
    required List<Conversation> conversations,
  }) = _ConversationsResponse;

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationsResponseFromJson(json);
}

@freezed
class ConversationsParams with _$ConversationsParams {
  const factory ConversationsParams({
    @Default(1) int page,
    @Default(10) int pageSize,
    @Default('created_at') String orderBy,
    @Default('desc') String orderDirection,
    @Default('') String searchTerm,
    @Default('') String filters,
    @Default('CHAT') String conversationType,
  }) = _ConversationsParams;

  factory ConversationsParams.fromJson(Map<String, dynamic> json) =>
      _$ConversationsParamsFromJson(json);
}