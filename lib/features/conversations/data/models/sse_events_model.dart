import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/sse_events.dart';

part 'sse_events_model.freezed.dart';
part 'sse_events_model.g.dart';

@freezed
class SSEEventModel with _$SSEEventModel {
  const factory SSEEventModel.userMessage({
    required SSEUserMessageDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEUserMessageEventModel;

  const factory SSEEventModel.agentMessage({
    required SSEAgentMessageDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEAgentMessageEventModel;

  const factory SSEEventModel.llmResponseStart({
    required SSELLMResponseStartDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSELLMResponseStartEventModel;

  const factory SSEEventModel.llmResponseEnd({
    required SSELLMResponseEndDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSELLMResponseEndEventModel;

  const factory SSEEventModel.llmResponseError({
    required SSELLMResponseErrorDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSELLMResponseErrorEventModel;

  const factory SSEEventModel.agentAssigned({
    required SSEAgentAssignedDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEAgentAssignedEventModel;

  const factory SSEEventModel.conversationStatusChange({
    required SSEConversationStatusChangeDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEConversationStatusChangeEventModel;

  const factory SSEEventModel.typing({
    required SSETypingDataModel data,
    @JsonKey(name: 'conversation_id') required int conversationId,
    @JsonKey(name: 'organization_id') required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSETypingEventModel;

  const factory SSEEventModel.keepalive() = SSEKeepaliveEventModel;

  const SSEEventModel._();

  factory SSEEventModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    switch (type) {
      case 'user_message':
        return SSEEventModel.userMessage(
          data: SSEUserMessageDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'agent_message':
        return SSEEventModel.agentMessage(
          data: SSEAgentMessageDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'llm_response_start':
        return SSEEventModel.llmResponseStart(
          data: SSELLMResponseStartDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'llm_response_end':
        return SSEEventModel.llmResponseEnd(
          data: SSELLMResponseEndDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'llm_response_error':
        return SSEEventModel.llmResponseError(
          data: SSELLMResponseErrorDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'agent_assigned':
        return SSEEventModel.agentAssigned(
          data: SSEAgentAssignedDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'conversation_status_change':
        return SSEEventModel.conversationStatusChange(
          data: SSEConversationStatusChangeDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'typing_start':
      case 'typing_end':
        return SSEEventModel.typing(
          data: SSETypingDataModel.fromJson(json['data']),
          conversationId: json['conversation_id'],
          organizationId: json['organization_id'],
          platform: json['platform'],
          timestamp: json['timestamp'],
        );
      case 'keepalive':
        return const SSEEventModel.keepalive();
      default:
        throw UnsupportedError('Unknown SSE event type: $type');
    }
  }

  SSEEvent toDomain() {
    return when(
      userMessage: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.userMessage(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      agentMessage: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.agentMessage(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      llmResponseStart: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.llmResponseStart(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      llmResponseEnd: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.llmResponseEnd(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      llmResponseError: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.llmResponseError(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      agentAssigned: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.agentAssigned(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      conversationStatusChange: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.conversationStatusChange(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      typing: (data, conversationId, organizationId, platform, timestamp) =>
          SSEEvent.typing(
        data: data.toDomain(),
        conversationId: conversationId,
        organizationId: organizationId,
        platform: platform,
        timestamp: timestamp,
      ),
      keepalive: () => const SSEEvent.keepalive(),
    );
  }
}

@freezed
class SSEUserMessageDataModel with _$SSEUserMessageDataModel {
  const factory SSEUserMessageDataModel({
    required String message,
    @JsonKey(name: 'message_type') required String messageType,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'session_id') required String sessionId,
    required Map<String, dynamic> metadata,
  }) = _SSEUserMessageDataModel;

  const SSEUserMessageDataModel._();

  factory SSEUserMessageDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSEUserMessageDataModelFromJson(json);

  SSEUserMessageData toDomain() {
    return SSEUserMessageData(
      message: message,
      messageType: messageType,
      userId: userId,
      sessionId: sessionId,
      metadata: metadata,
    );
  }
}

@freezed
class SSEAgentMessageDataModel with _$SSEAgentMessageDataModel {
  const factory SSEAgentMessageDataModel({
    required String message,
    @JsonKey(name: 'message_type') required String messageType,
    @JsonKey(name: 'agent_id') required int agentId,
    @JsonKey(name: 'session_id') required String sessionId,
    Map<String, dynamic>? metadata,
  }) = _SSEAgentMessageDataModel;

  const SSEAgentMessageDataModel._();

  factory SSEAgentMessageDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSEAgentMessageDataModelFromJson(json);

  SSEAgentMessageData toDomain() {
    return SSEAgentMessageData(
      message: message,
      messageType: messageType,
      agentId: agentId,
      sessionId: sessionId,
      metadata: metadata,
    );
  }
}

@freezed
class SSELLMResponseStartDataModel with _$SSELLMResponseStartDataModel {
  const factory SSELLMResponseStartDataModel({
    required String status,
    @JsonKey(name: 'model_name') required String modelName,
    required Map<String, dynamic> metadata,
  }) = _SSELLMResponseStartDataModel;

  const SSELLMResponseStartDataModel._();

  factory SSELLMResponseStartDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSELLMResponseStartDataModelFromJson(json);

  SSELLMResponseStartData toDomain() {
    return SSELLMResponseStartData(
      status: status,
      modelName: modelName,
      metadata: metadata,
    );
  }
}

@freezed
class SSELLMResponseEndDataModel with _$SSELLMResponseEndDataModel {
  const factory SSELLMResponseEndDataModel({
    required String response,
    required String status,
    @JsonKey(name: 'model_name') required String modelName,
    @JsonKey(name: 'processing_time') required double processingTime,
    @JsonKey(name: 'token_count') required int tokenCount,
    required Map<String, dynamic> metadata,
  }) = _SSELLMResponseEndDataModel;

  const SSELLMResponseEndDataModel._();

  factory SSELLMResponseEndDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSELLMResponseEndDataModelFromJson(json);

  SSELLMResponseEndData toDomain() {
    return SSELLMResponseEndData(
      response: response,
      status: status,
      modelName: modelName,
      processingTime: processingTime,
      tokenCount: tokenCount,
      metadata: metadata,
    );
  }
}

@freezed
class SSELLMResponseErrorDataModel with _$SSELLMResponseErrorDataModel {
  const factory SSELLMResponseErrorDataModel({
    required String error,
    @JsonKey(name: 'error_code') required String errorCode,
    required String status,
    required Map<String, dynamic> metadata,
  }) = _SSELLMResponseErrorDataModel;

  const SSELLMResponseErrorDataModel._();

  factory SSELLMResponseErrorDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSELLMResponseErrorDataModelFromJson(json);

  SSELLMResponseErrorData toDomain() {
    return SSELLMResponseErrorData(
      error: error,
      errorCode: errorCode,
      status: status,
      metadata: metadata,
    );
  }
}

@freezed
class SSEAgentAssignedDataModel with _$SSEAgentAssignedDataModel {
  const factory SSEAgentAssignedDataModel({
    @JsonKey(name: 'agent_id') required int agentId,
    @JsonKey(name: 'agent_name') required String agentName,
  }) = _SSEAgentAssignedDataModel;

  const SSEAgentAssignedDataModel._();

  factory SSEAgentAssignedDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSEAgentAssignedDataModelFromJson(json);

  SSEAgentAssignedData toDomain() {
    return SSEAgentAssignedData(
      agentId: agentId,
      agentName: agentName,
    );
  }
}

@freezed
class SSEConversationStatusChangeDataModel with _$SSEConversationStatusChangeDataModel {
  const factory SSEConversationStatusChangeDataModel({
    @JsonKey(name: 'old_status') required String oldStatus,
    @JsonKey(name: 'new_status') required String newStatus,
    @JsonKey(name: 'changed_by') required int changedBy,
  }) = _SSEConversationStatusChangeDataModel;

  const SSEConversationStatusChangeDataModel._();

  factory SSEConversationStatusChangeDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSEConversationStatusChangeDataModelFromJson(json);

  SSEConversationStatusChangeData toDomain() {
    return SSEConversationStatusChangeData(
      oldStatus: oldStatus,
      newStatus: newStatus,
      changedBy: changedBy,
    );
  }
}

@freezed
class SSETypingDataModel with _$SSETypingDataModel {
  const factory SSETypingDataModel({
    required String status,
    @JsonKey(name: 'typing_by') required TypingBy typingBy,
  }) = _SSETypingDataModel;

  const SSETypingDataModel._();

  factory SSETypingDataModel.fromJson(Map<String, dynamic> json) =>
      _$SSETypingDataModelFromJson(json);

  SSETypingData toDomain() {
    return SSETypingData(
      status: status,
      typingBy: typingBy,
    );
  }
}