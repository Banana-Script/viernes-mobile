import '../../domain/entities/conversation_entity.dart';
import 'customer_detail_model.dart';

/// Conversation Model
///
/// Data model for conversation that extends the domain entity.
/// Handles JSON serialization/deserialization.
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.userId,
    super.user,
    super.agent,
    super.status,
    super.tags,
    super.assigns,
    required super.organizationId,
    required super.statusId,
    super.agentId,
    super.priority,
    super.category,
    super.sentiment,
    required super.type,
    required super.createdAt,
    required super.updatedAt,
    super.firstResponseAt,
    super.integrationId,
    required super.readed,
    required super.locked,
    super.memory,
    required super.unreaded,
    super.callId,
    super.campaignId,
    super.callDate,
  });

  /// Create from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      user: json['user'] != null
          ? CustomerDetailModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      agent: json['agent'] != null
          ? ConversationAgentModel.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      status: json['status'] != null
          ? ConversationStatusModel.fromJson(json['status'] as Map<String, dynamic>)
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List)
              .map((t) => ConversationTagModel.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
      assigns: json['assigns'] != null
          ? (json['assigns'] as List)
              .map((a) => ConversationAssignModel.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      organizationId: json['organization_id'] as int,
      statusId: json['status_id'] as int,
      agentId: json['agent_id'] as int?,
      priority: json['priority'] as String?,
      category: json['category'] as String?,
      sentiment: json['sentiment'] as String?,
      type: ConversationType.fromString(json['type'] as String? ?? 'CHAT'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      firstResponseAt: json['first_response_at'] != null
          ? DateTime.parse(json['first_response_at'] as String)
          : null,
      integrationId: json['integration_id'] as int?,
      readed: json['readed'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      memory: json['memory'] is Map
          ? null // If it's a Map, we can't use it as a String, so set to null
          : json['memory'] as String?,
      unreaded: json['unreaded'] as int? ?? 0,
      callId: json['call_id'] as int?,
      campaignId: json['campaign_id'] as int?,
      callDate: json['call_date'] != null
          ? DateTime.parse(json['call_date'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user': user != null ? (user as CustomerDetailModel).toJson() : null,
      'agent': agent != null ? (agent as ConversationAgentModel).toJson() : null,
      'status': status != null ? (status as ConversationStatusModel).toJson() : null,
      'tags': tags.map((t) => (t as ConversationTagModel).toJson()).toList(),
      'assigns': assigns.map((a) => (a as ConversationAssignModel).toJson()).toList(),
      'organization_id': organizationId,
      'status_id': statusId,
      'agent_id': agentId,
      'priority': priority,
      'category': category,
      'sentiment': sentiment,
      'type': type.toApiString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'first_response_at': firstResponseAt?.toIso8601String(),
      'integration_id': integrationId,
      'readed': readed,
      'locked': locked,
      'memory': memory,
      'unreaded': unreaded,
      'call_id': callId,
      'campaign_id': campaignId,
      'call_date': callDate?.toIso8601String(),
    };
  }
}

/// Conversation Agent Model
class ConversationAgentModel extends ConversationAgent {
  const ConversationAgentModel({
    required super.id,
    required super.fullname,
    required super.email,
  });

  factory ConversationAgentModel.fromJson(Map<String, dynamic> json) {
    return ConversationAgentModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
    };
  }
}

/// Conversation Status Model
class ConversationStatusModel extends ConversationStatus {
  const ConversationStatusModel({
    required super.id,
    required super.valueDefinition,
    required super.description,
  });

  factory ConversationStatusModel.fromJson(Map<String, dynamic> json) {
    return ConversationStatusModel(
      id: json['id'] as int,
      valueDefinition: json['value_definition'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value_definition': valueDefinition,
      'description': description,
    };
  }
}

/// Conversation Tag Model
class ConversationTagModel extends ConversationTag {
  const ConversationTagModel({
    required super.id,
    required super.tagName,
    required super.description,
  });

  factory ConversationTagModel.fromJson(Map<String, dynamic> json) {
    return ConversationTagModel(
      id: json['id'] as int,
      tagName: json['tag_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_name': tagName,
      'description': description,
    };
  }
}

/// Conversation Assign Model
class ConversationAssignModel extends ConversationAssign {
  const ConversationAssignModel({
    required super.id,
    required super.userId,
    required super.user,
    required super.conversationId,
    required super.createdAt,
  });

  factory ConversationAssignModel.fromJson(Map<String, dynamic> json) {
    return ConversationAssignModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      user: AssignedUserModel.fromJson(json['user'] as Map<String, dynamic>),
      conversationId: json['conversation_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user': (user as AssignedUserModel).toJson(),
      'conversation_id': conversationId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Assigned User Model
class AssignedUserModel extends AssignedUser {
  const AssignedUserModel({
    required super.id,
    required super.fullname,
    required super.email,
  });

  factory AssignedUserModel.fromJson(Map<String, dynamic> json) {
    return AssignedUserModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
    };
  }
}

/// Conversations Response Model
class ConversationsResponseModel {
  final List<ConversationModel> conversations;
  final int totalCount;
  final int currentPage;
  final int totalPages;

  const ConversationsResponseModel({
    required this.conversations,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
  });

  factory ConversationsResponseModel.fromJson(Map<String, dynamic> json) {
    return ConversationsResponseModel(
      conversations: (json['data'] as List?)
              ?.map((c) => ConversationModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  bool get hasMorePages => currentPage < totalPages;
}
