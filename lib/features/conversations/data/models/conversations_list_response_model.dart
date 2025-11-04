import '../../domain/repositories/conversation_repository.dart';
import '../../../customers/data/models/conversation_model.dart';

/// Conversations List Response Model
///
/// Data model for conversations list response with pagination.
class ConversationsListResponseModel extends ConversationsListResponse {
  const ConversationsListResponseModel({
    required super.conversations,
    required super.totalCount,
    required super.currentPage,
    required super.totalPages,
  });

  /// Create from JSON
  factory ConversationsListResponseModel.fromJson(Map<String, dynamic> json) {
    return ConversationsListResponseModel(
      conversations: (json['conversations'] as List?)
              ?.map((c) => ConversationModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': conversations.map((c) => (c as ConversationModel).toJson()).toList(),
      'total': totalCount,
      'current_page': currentPage,
      'total_pages': totalPages,
    };
  }
}

/// Status Option Model
class ConversationStatusOptionModel extends ConversationStatusOption {
  const ConversationStatusOptionModel({
    required super.id,
    required super.value,
    required super.label,
    required super.description,
  });

  factory ConversationStatusOptionModel.fromJson(Map<String, dynamic> json) {
    return ConversationStatusOptionModel(
      id: json['id'] as int,
      value: json['value_definition'] as String? ?? '',
      label: json['value_definition'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value_definition': value,
      'description': description,
    };
  }
}

/// Tag Option Model
class TagOptionModel extends TagOption {
  const TagOptionModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory TagOptionModel.fromJson(Map<String, dynamic> json) {
    return TagOptionModel(
      id: json['id'] as int,
      name: json['tag_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_name': name,
      'description': description,
    };
  }
}

/// Agent Option Model
class AgentOptionModel extends AgentOption {
  const AgentOptionModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory AgentOptionModel.fromJson(Map<String, dynamic> json) {
    return AgentOptionModel(
      id: json['id'] as int,
      name: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': name,
      'email': email,
    };
  }
}
