// SSE Events Models
//
// Event types and payloads for Server-Sent Events from the backend.
// Based on the web frontend implementation.

/// Helper to parse timestamp which can come as int or double from backend
double? _parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return null;
}

/// SSE Event Types
enum SSEEventType {
  // Organization-level events
  agentAssigned('agent_assigned'),
  newConversation('new_conversation'),
  newMessage('new_message'),
  userMessage('user_message'),
  messageReceived('message_received'),

  // Conversation-level events
  agentMessage('agent_message'),
  llmResponseStart('llm_response_start'),
  llmResponseEnd('llm_response_end'),
  llmResponseError('llm_response_error'),
  typingStart('typing_start'),
  typingEnd('typing_end'),
  conversationStatusChange('conversation_status_change'),

  // Connection events
  keepalive('keepalive'),
  unknown('unknown');

  final String value;
  const SSEEventType(this.value);

  static SSEEventType fromString(String value) {
    return SSEEventType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SSEEventType.unknown,
    );
  }
}

/// Base SSE Event
abstract class SSEEvent {
  final SSEEventType type;
  final int? conversationId;
  final int? organizationId;
  final String? platform;
  final double? timestamp;

  const SSEEvent({
    required this.type,
    this.conversationId,
    this.organizationId,
    this.platform,
    this.timestamp,
  });

  factory SSEEvent.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String? ?? 'unknown';
    final type = SSEEventType.fromString(typeString);

    switch (type) {
      case SSEEventType.agentAssigned:
        return SSEAgentAssignedEvent.fromJson(json);
      case SSEEventType.newConversation:
        return SSENewConversationEvent.fromJson(json);
      case SSEEventType.userMessage:
      case SSEEventType.newMessage:
      case SSEEventType.messageReceived:
        return SSEUserMessageEvent.fromJson(json);
      case SSEEventType.agentMessage:
        return SSEAgentMessageEvent.fromJson(json);
      case SSEEventType.llmResponseStart:
        return SSELLMResponseStartEvent.fromJson(json);
      case SSEEventType.llmResponseEnd:
        return SSELLMResponseEndEvent.fromJson(json);
      case SSEEventType.llmResponseError:
        return SSELLMResponseErrorEvent.fromJson(json);
      case SSEEventType.typingStart:
      case SSEEventType.typingEnd:
        return SSETypingEvent.fromJson(json);
      case SSEEventType.conversationStatusChange:
        return SSEConversationStatusChangeEvent.fromJson(json);
      case SSEEventType.keepalive:
        return SSEKeepaliveEvent.fromJson(json);
      default:
        return SSEUnknownEvent.fromJson(json);
    }
  }
}

/// Agent Assigned Event
class SSEAgentAssignedEvent extends SSEEvent {
  final int agentId;
  final String agentName;

  const SSEAgentAssignedEvent({
    required this.agentId,
    required this.agentName,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.agentAssigned);

  factory SSEAgentAssignedEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SSEAgentAssignedEvent(
      agentId: data['agent_id'] as int? ?? 0,
      agentName: data['agent_name'] as String? ?? '',
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// New Conversation Event
class SSENewConversationEvent extends SSEEvent {
  final int userId;
  final String userName;
  final String userPhone;
  final String createdAt;
  final Map<String, dynamic> metadata;

  const SSENewConversationEvent({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
    required this.metadata,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.newConversation);

  factory SSENewConversationEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SSENewConversationEvent(
      userId: data['user_id'] as int? ?? 0,
      userName: data['user_name'] as String? ?? '',
      userPhone: data['user_phone'] as String? ?? '',
      createdAt: data['created_at'] as String? ?? '',
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      conversationId: json['conversation_id'] as int? ?? data['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// User Message Event
class SSEUserMessageEvent extends SSEEvent {
  final String message;
  final String messageType;
  final int? userId;
  final String? sessionId;
  final int? agentId;
  final Map<String, dynamic> metadata;

  const SSEUserMessageEvent({
    required this.message,
    required this.messageType,
    this.userId,
    this.sessionId,
    this.agentId,
    required this.metadata,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.userMessage);

  factory SSEUserMessageEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SSEUserMessageEvent(
      message: data['message'] as String? ?? '',
      messageType: data['message_type'] as String? ?? 'text',
      userId: data['user_id'] as int?,
      sessionId: data['session_id'] as String?,
      agentId: data['agent_id'] as int?,
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// Agent Message Event
class SSEAgentMessageEvent extends SSEEvent {
  final String message;
  final String messageType;
  final int? agentId;
  final String? agentName;
  final String? sessionId;
  final Map<String, dynamic> metadata;

  const SSEAgentMessageEvent({
    required this.message,
    required this.messageType,
    this.agentId,
    this.agentName,
    this.sessionId,
    required this.metadata,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.agentMessage);

  factory SSEAgentMessageEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SSEAgentMessageEvent(
      message: data['message'] as String? ?? '',
      messageType: data['message_type'] as String? ?? 'text',
      agentId: data['agent_id'] as int?,
      agentName: data['agent_name'] as String?,
      sessionId: data['session_id'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }

  /// Check if this is a replace message action
  bool get isReplaceAction => metadata['action'] == 'replace_loading_message';
}

/// LLM Response Start Event
class SSELLMResponseStartEvent extends SSEEvent {
  const SSELLMResponseStartEvent({
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.llmResponseStart);

  factory SSELLMResponseStartEvent.fromJson(Map<String, dynamic> json) {
    return SSELLMResponseStartEvent(
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// LLM Response End Event
class SSELLMResponseEndEvent extends SSEEvent {
  final String message;
  final String messageType;

  const SSELLMResponseEndEvent({
    required this.message,
    required this.messageType,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.llmResponseEnd);

  factory SSELLMResponseEndEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SSELLMResponseEndEvent(
      // Backend sends 'response' field, not 'message'
      message: data['response'] as String? ?? data['message'] as String? ?? '',
      messageType: data['message_type'] as String? ?? 'text',
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// LLM Response Error Event
class SSELLMResponseErrorEvent extends SSEEvent {
  final String error;

  const SSELLMResponseErrorEvent({
    required this.error,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.llmResponseError);

  factory SSELLMResponseErrorEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SSELLMResponseErrorEvent(
      error: data['error'] as String? ?? 'Unknown error',
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// Typing Event
class SSETypingEvent extends SSEEvent {
  final String typingBy;
  final bool isTyping;

  SSETypingEvent({
    required this.typingBy,
    required super.type,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : isTyping = type == SSEEventType.typingStart;

  factory SSETypingEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final typeString = json['type'] as String? ?? 'typing_end';
    return SSETypingEvent(
      typingBy: data['typing_by'] as String? ?? 'user',
      type: SSEEventType.fromString(typeString),
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// Conversation Status Change Event
class SSEConversationStatusChangeEvent extends SSEEvent {
  final String oldStatus;
  final String newStatus;

  const SSEConversationStatusChangeEvent({
    required this.oldStatus,
    required this.newStatus,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.conversationStatusChange);

  factory SSEConversationStatusChangeEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return SSEConversationStatusChangeEvent(
      oldStatus: data['old_status'] as String? ?? '',
      newStatus: data['new_status'] as String? ?? '',
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// Keepalive Event
class SSEKeepaliveEvent extends SSEEvent {
  const SSEKeepaliveEvent({
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.keepalive);

  factory SSEKeepaliveEvent.fromJson(Map<String, dynamic> json) {
    return SSEKeepaliveEvent(
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// Unknown Event
class SSEUnknownEvent extends SSEEvent {
  final Map<String, dynamic> rawData;

  const SSEUnknownEvent({
    required this.rawData,
    super.conversationId,
    super.organizationId,
    super.platform,
    super.timestamp,
  }) : super(type: SSEEventType.unknown);

  factory SSEUnknownEvent.fromJson(Map<String, dynamic> json) {
    return SSEUnknownEvent(
      rawData: json,
      conversationId: json['conversation_id'] as int?,
      organizationId: json['organization_id'] as int?,
      platform: json['platform'] as String?,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }
}

/// SSE Connection State
enum SSEConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}
