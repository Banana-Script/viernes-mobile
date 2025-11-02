import '../../domain/entities/customer_entity.dart';

/// Customer Model
///
/// Data model for customer that extends the domain entity.
/// Handles JSON serialization/deserialization.
class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.createdAt,
    super.segment,
    super.segmentSummary,
    super.segmentDescription,
    super.segmentDate,
    super.lastInteraction,
    super.insightsInfo,
    super.assignedAgent,
    super.lastConversation,
  });

  /// Create from JSON
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      segment: json['segment'] as String?,
      segmentSummary: json['segment_summary'] as String?,
      segmentDescription: json['segment_description'] as String?,
      segmentDate: json['segment_date'] != null
          ? DateTime.parse(json['segment_date'] as String)
          : null,
      lastInteraction: json['last_interaction'] != null
          ? DateTime.parse(json['last_interaction'] as String)
          : null,
      insightsInfo: json['insights_info'] != null
          ? (json['insights_info'] as List)
              .whereType<Map<String, dynamic>>()
              .map((i) => InsightInfoModel.fromJson(i))
              .toList()
          : [],
      assignedAgent: json['assigned_agent'] != null && json['assigned_agent'] is Map<String, dynamic>
          ? AssignedAgentModel.fromJson(json['assigned_agent'] as Map<String, dynamic>)
          : null,
      lastConversation: json['last_conversation'] != null && json['last_conversation'] is Map<String, dynamic>
          ? LastConversationModel.fromJson(json['last_conversation'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'segment': segment,
      'segment_summary': segmentSummary,
      'segment_description': segmentDescription,
      'segment_date': segmentDate?.toIso8601String(),
      'last_interaction': lastInteraction?.toIso8601String(),
      'insights_info': insightsInfo.map((i) => (i as InsightInfoModel).toJson()).toList(),
      'assigned_agent': assignedAgent != null
          ? (assignedAgent as AssignedAgentModel).toJson()
          : null,
      'last_conversation': lastConversation != null
          ? (lastConversation as LastConversationModel).toJson()
          : null,
    };
  }
}

/// Insight Info Model
class InsightInfoModel extends InsightInfo {
  const InsightInfoModel({
    required super.feature,
    super.value,
  });

  factory InsightInfoModel.fromJson(Map<String, dynamic> json) {
    return InsightInfoModel(
      feature: json['feature'] as String,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feature': feature,
      'value': value,
    };
  }
}

/// Assigned Agent Model
class AssignedAgentModel extends AssignedAgent {
  const AssignedAgentModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory AssignedAgentModel.fromJson(Map<String, dynamic> json) {
    return AssignedAgentModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

/// Last Conversation Model
class LastConversationModel extends LastConversation {
  const LastConversationModel({
    required super.id,
    required super.readed,
    required super.locked,
    super.updatedAt,
  });

  factory LastConversationModel.fromJson(Map<String, dynamic> json) {
    return LastConversationModel(
      id: json['id'] as int,
      readed: json['readed'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'readed': readed,
      'locked': locked,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
