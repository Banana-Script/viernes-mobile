import 'dart:convert';
import '../../domain/entities/message_entity.dart';

/// Message Model
///
/// Data model for message that extends the domain entity.
/// Handles JSON serialization/deserialization.
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    super.text,
    super.media,
    super.mediaType,
    super.fileName,
    required super.fromUser,
    required super.fromAgent,
    required super.createdAt,
    super.status,
    required super.type,
    super.agentId,
    super.agentName,
    super.metadata,
  });

  /// Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Determine message type from 'type' field ('user', 'gpt', 'agent', etc)
    final messageType = json['type'] as String? ?? 'text';
    final fromUser = messageType.toLowerCase() == 'user';
    final fromAgent = messageType.toLowerCase() == 'gpt' || messageType.toLowerCase() == 'agent';

    return MessageModel(
      id: json['id'] as int,
      conversationId: json['parent_conversation_id'] as int,
      text: json['message'] as String?,
      media: json['media'] as String?,
      mediaType: json['media_type'] as String?,
      fileName: json['file_name'] as String?,
      fromUser: fromUser,
      fromAgent: fromAgent,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['readed'] as bool? ?? false ? 'read' : 'sent',
      type: MessageType.fromString(messageType),
      agentId: json['agent_id'] as int?,
      agentName: json['agent_name'] as String?,
      metadata: json['json_message'] != null && json['json_message'] is String
          ? (jsonDecode(json['json_message'] as String) as Map<String, dynamic>?)
          : (json['json_message'] as Map<String, dynamic>?),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'text': text,
      'media': media,
      'media_type': mediaType,
      'file_name': fileName,
      'from_user': fromUser,
      'from_agent': fromAgent,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'type': type.toApiString(),
      'agent_id': agentId,
      'agent_name': agentName,
      'metadata': metadata,
    };
  }
}

/// Messages Response Model
class MessagesResponseModel extends MessagesResponse {
  const MessagesResponseModel({
    required super.messages,
    required super.totalCount,
    required super.currentPage,
    required super.totalPages,
    required super.hasNextPage,
    required super.hasPreviousPage,
  });

  /// Create from JSON
  factory MessagesResponseModel.fromJson(Map<String, dynamic> json) {
    final messagesList = (json['conversation'] as List?)
            ?.map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    // The API doesn't return pagination info for messages endpoint
    // So we calculate it based on the messages array
    final totalCount = messagesList.length;

    return MessagesResponseModel(
      messages: messagesList,
      totalCount: totalCount,
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      hasNextPage: json['has_next_page'] as bool? ?? false,
      hasPreviousPage: json['has_previous_page'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': messages.map((m) => (m as MessageModel).toJson()).toList(),
      'total': totalCount,
      'current_page': currentPage,
      'total_pages': totalPages,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }
}
