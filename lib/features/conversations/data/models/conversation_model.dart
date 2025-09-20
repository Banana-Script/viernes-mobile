import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/conversation_agent.dart';
import '../../domain/entities/conversation_status.dart';
import '../../domain/entities/conversation_tag.dart';
import '../../domain/entities/conversation_assign.dart';
import '../../domain/entities/conversation_integration.dart';
import 'conversation_user_model.dart';

part 'conversation_model.freezed.dart';
part 'conversation_model.g.dart';

@freezed
class ConversationModel with _$ConversationModel {
  const factory ConversationModel({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    required ConversationUserModel user,
    ConversationAgentModel? agent,
    required ConversationStatusModel status,
    @Default([]) List<ConversationTagModel> tags,
    ConversationAssignModel? assigns,
    @JsonKey(name: 'organization_id') required int organizationId,
    @JsonKey(name: 'status_id') required int statusId,
    @JsonKey(name: 'agent_id') int? agentId,
    required String priority,
    required String category,
    required String sentiment,
    required String type,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'first_response_at') String? firstResponseAt,
    @JsonKey(name: 'integration_id') int? integrationId,
    ConversationIntegrationModel? integration,
    required bool readed,
    required bool locked,
    String? memory,
    required int unreaded,
  }) = _ConversationModel;

  const ConversationModel._();

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Conversation toDomain() {
    return Conversation(
      id: id,
      userId: userId,
      user: user.toDomain(),
      agent: agent?.toDomain(),
      status: status.toDomain(),
      tags: tags.map((t) => t.toDomain()).toList(),
      assigns: assigns?.toDomain(),
      organizationId: organizationId,
      statusId: statusId,
      agentId: agentId,
      priority: priority,
      category: category,
      sentiment: sentiment,
      type: type,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      firstResponseAt: firstResponseAt != null ? DateTime.parse(firstResponseAt!) : null,
      integrationId: integrationId,
      integration: integration?.toDomain(),
      readed: readed,
      locked: locked,
      memory: memory,
      unreaded: unreaded,
    );
  }
}

@freezed
class ConversationAgentModel with _$ConversationAgentModel {
  const factory ConversationAgentModel({
    required int id,
    required String fullname,
    required String email,
  }) = _ConversationAgentModel;

  const ConversationAgentModel._();

  factory ConversationAgentModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationAgentModelFromJson(json);

  ConversationAgent toDomain() {
    return ConversationAgent(
      id: id,
      fullname: fullname,
      email: email,
    );
  }
}

@freezed
class ConversationStatusModel with _$ConversationStatusModel {
  const factory ConversationStatusModel({
    required int id,
    @JsonKey(name: 'value_definition') required String valueDefinition,
    required String description,
    required String active,
    @JsonKey(name: 'validation_type') String? validationType,
    @JsonKey(name: 'definition_type_id') required int definitionTypeId,
    @JsonKey(name: 'definition_type') required ConversationDefinitionTypeModel definitionType,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ConversationStatusModel;

  const ConversationStatusModel._();

  factory ConversationStatusModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationStatusModelFromJson(json);

  ConversationStatus toDomain() {
    return ConversationStatus(
      id: id,
      valueDefinition: valueDefinition,
      description: description,
      active: active,
      validationType: validationType,
      definitionTypeId: definitionTypeId,
      definitionType: definitionType.toDomain(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}

@freezed
class ConversationDefinitionTypeModel with _$ConversationDefinitionTypeModel {
  const factory ConversationDefinitionTypeModel({
    required int id,
    @JsonKey(name: 'definition_type') required String definitionType,
    required String description,
    required String active,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ConversationDefinitionTypeModel;

  const ConversationDefinitionTypeModel._();

  factory ConversationDefinitionTypeModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationDefinitionTypeModelFromJson(json);

  ConversationDefinitionType toDomain() {
    return ConversationDefinitionType(
      id: id,
      definitionType: definitionType,
      description: description,
      active: active,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}

@freezed
class ConversationTagModel with _$ConversationTagModel {
  const factory ConversationTagModel({
    required int id,
    @JsonKey(name: 'tag_name') required String tagName,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String description,
    @JsonKey(name: 'modified_by_id') int? modifiedById,
    @JsonKey(name: 'applied_by_id') int? appliedById,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ConversationTagModel;

  const ConversationTagModel._();

  factory ConversationTagModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationTagModelFromJson(json);

  ConversationTag toDomain() {
    return ConversationTag(
      id: id,
      tagName: tagName,
      organizationId: organizationId,
      description: description,
      modifiedById: modifiedById,
      appliedById: appliedById,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}

@freezed
class ConversationAssignModel with _$ConversationAssignModel {
  const factory ConversationAssignModel({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    required ConversationAssignUserModel user,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _ConversationAssignModel;

  const ConversationAssignModel._();

  factory ConversationAssignModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationAssignModelFromJson(json);

  ConversationAssign toDomain() {
    return ConversationAssign(
      id: id,
      userId: userId,
      user: user.toDomain(),
      conversationId: conversationId,
      createdAt: DateTime.parse(createdAt),
    );
  }
}

@freezed
class ConversationAssignUserModel with _$ConversationAssignUserModel {
  const factory ConversationAssignUserModel({
    required int id,
    required String fullname,
    required String email,
  }) = _ConversationAssignUserModel;

  const ConversationAssignUserModel._();

  factory ConversationAssignUserModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationAssignUserModelFromJson(json);

  ConversationAssignUser toDomain() {
    return ConversationAssignUser(
      id: id,
      fullname: fullname,
      email: email,
    );
  }
}

@freezed
class ConversationIntegrationModel with _$ConversationIntegrationModel {
  const factory ConversationIntegrationModel({
    required int id,
    required String name,
    required String type,
  }) = _ConversationIntegrationModel;

  const ConversationIntegrationModel._();

  factory ConversationIntegrationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationIntegrationModelFromJson(json);

  ConversationIntegration toDomain() {
    return ConversationIntegration(
      id: id,
      name: name,
      type: type,
    );
  }
}

@freezed
class ConversationsResponseModel with _$ConversationsResponseModel {
  const factory ConversationsResponseModel({
    @JsonKey(name: 'total_count') required int totalCount,
    @JsonKey(name: 'total_pages') required int totalPages,
    @JsonKey(name: 'current_page') required int currentPage,
    @JsonKey(name: 'page_size') required int pageSize,
    required List<ConversationModel> conversations,
  }) = _ConversationsResponseModel;

  const ConversationsResponseModel._();

  factory ConversationsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationsResponseModelFromJson(json);

  ConversationsResponse toDomain() {
    return ConversationsResponse(
      totalCount: totalCount,
      totalPages: totalPages,
      currentPage: currentPage,
      pageSize: pageSize,
      conversations: conversations.map((c) => c.toDomain()).toList(),
    );
  }
}

@freezed
class ConversationsParamsModel with _$ConversationsParamsModel {
  const factory ConversationsParamsModel({
    @Default(1) int page,
    @JsonKey(name: 'page_size') @Default(10) int pageSize,
    @JsonKey(name: 'order_by') @Default('created_at') String orderBy,
    @JsonKey(name: 'order_direction') @Default('desc') String orderDirection,
    @JsonKey(name: 'search_term') @Default('') String searchTerm,
    @Default('') String filters,
    @JsonKey(name: 'conversation_type') @Default('CHAT') String conversationType,
  }) = _ConversationsParamsModel;

  const ConversationsParamsModel._();

  factory ConversationsParamsModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationsParamsModelFromJson(json);

  ConversationsParams toDomain() {
    return ConversationsParams(
      page: page,
      pageSize: pageSize,
      orderBy: orderBy,
      orderDirection: orderDirection,
      searchTerm: searchTerm,
      filters: filters,
      conversationType: conversationType,
    );
  }

  factory ConversationsParamsModel.fromDomain(ConversationsParams params) {
    return ConversationsParamsModel(
      page: params.page,
      pageSize: params.pageSize,
      orderBy: params.orderBy,
      orderDirection: params.orderDirection,
      searchTerm: params.searchTerm,
      filters: params.filters,
      conversationType: params.conversationType,
    );
  }
}