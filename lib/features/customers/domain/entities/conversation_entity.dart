import 'customer_detail_entity.dart';

/// Conversation Entity
///
/// Domain entity representing a conversation with a customer.
/// Used in the customer detail view to show conversation history.
class ConversationEntity {
  final int id;
  final int userId;
  final CustomerDetailEntity? user;
  final ConversationAgent? agent;
  final ConversationStatus? status;
  final List<ConversationTag> tags;
  final List<ConversationAssign> assigns;
  final int organizationId;
  final int statusId;
  final int? agentId;
  final String? priority;
  final String? category;
  final String? sentiment;
  final ConversationType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? firstResponseAt;
  final int? integrationId;
  final bool readed;
  final bool locked;
  final String? memory;
  final int unreaded;
  final int? callId;
  final int? campaignId;
  final DateTime? callDate;

  const ConversationEntity({
    required this.id,
    required this.userId,
    this.user,
    this.agent,
    this.status,
    this.tags = const [],
    this.assigns = const [],
    required this.organizationId,
    required this.statusId,
    this.agentId,
    this.priority,
    this.category,
    this.sentiment,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.firstResponseAt,
    this.integrationId,
    required this.readed,
    required this.locked,
    this.memory,
    required this.unreaded,
    this.callId,
    this.campaignId,
    this.callDate,
  });

  /// Check if conversation is a call
  bool get isCall => type == ConversationType.call;

  /// Check if conversation is a chat
  bool get isChat => type == ConversationType.chat;

  /// Get conversation origin (Inbound/Outbound)
  String get origin {
    // Logic to determine if inbound or outbound
    // Could be based on campaign_id or other fields
    return campaignId != null ? 'Outbound' : 'Inbound';
  }
}

/// Conversation Type
enum ConversationType {
  chat,
  call;

  /// Convert from string
  static ConversationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CHAT':
        return ConversationType.chat;
      case 'CALL':
        return ConversationType.call;
      default:
        return ConversationType.chat;
    }
  }

  /// Convert to string
  String toApiString() {
    switch (this) {
      case ConversationType.chat:
        return 'CHAT';
      case ConversationType.call:
        return 'CALL';
    }
  }
}

/// Conversation Agent
class ConversationAgent {
  final int id;
  final String fullname;
  final String email;

  const ConversationAgent({
    required this.id,
    required this.fullname,
    required this.email,
  });
}

/// Conversation Status
class ConversationStatus {
  final int id;
  final String valueDefinition;
  final String description;

  const ConversationStatus({
    required this.id,
    required this.valueDefinition,
    required this.description,
  });
}

/// Conversation Tag
class ConversationTag {
  final int id;
  final String tagName;
  final String description;

  const ConversationTag({
    required this.id,
    required this.tagName,
    required this.description,
  });
}

/// Conversation Assign
class ConversationAssign {
  final int id;
  final int userId;
  final AssignedUser user;
  final int conversationId;
  final DateTime createdAt;

  const ConversationAssign({
    required this.id,
    required this.userId,
    required this.user,
    required this.conversationId,
    required this.createdAt,
  });
}

/// Assigned User (in conversation assign)
class AssignedUser {
  final int id;
  final String fullname;
  final String email;

  const AssignedUser({
    required this.id,
    required this.fullname,
    required this.email,
  });
}
