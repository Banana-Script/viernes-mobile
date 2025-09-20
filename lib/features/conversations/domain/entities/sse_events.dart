import 'package:freezed_annotation/freezed_annotation.dart';

part 'sse_events.freezed.dart';
part 'sse_events.g.dart';

@freezed
class SSEEvent with _$SSEEvent {
  const factory SSEEvent.userMessage({
    required SSEUserMessageData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEUserMessageEvent;

  const factory SSEEvent.agentMessage({
    required SSEAgentMessageData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEAgentMessageEvent;

  const factory SSEEvent.llmResponseStart({
    required SSELLMResponseStartData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSELLMResponseStartEvent;

  const factory SSEEvent.llmResponseEnd({
    required SSELLMResponseEndData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSELLMResponseEndEvent;

  const factory SSEEvent.llmResponseError({
    required SSELLMResponseErrorData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSELLMResponseErrorEvent;

  const factory SSEEvent.agentAssigned({
    required SSEAgentAssignedData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEAgentAssignedEvent;

  const factory SSEEvent.conversationStatusChange({
    required SSEConversationStatusChangeData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSEConversationStatusChangeEvent;

  const factory SSEEvent.typing({
    required SSETypingData data,
    required int conversationId,
    required int organizationId,
    required String platform,
    required int timestamp,
  }) = SSETypingEvent;

  const factory SSEEvent.keepalive() = SSEKeepaliveEvent;

  factory SSEEvent.fromJson(Map<String, dynamic> json) => _$SSEEventFromJson(json);
}

@freezed
class SSEUserMessageData with _$SSEUserMessageData {
  const factory SSEUserMessageData({
    required String message,
    required String messageType,
    required int userId,
    required String sessionId,
    required Map<String, dynamic> metadata,
  }) = _SSEUserMessageData;

  factory SSEUserMessageData.fromJson(Map<String, dynamic> json) =>
      _$SSEUserMessageDataFromJson(json);
}

@freezed
class SSEAgentMessageData with _$SSEAgentMessageData {
  const factory SSEAgentMessageData({
    required String message,
    required String messageType,
    required int agentId,
    required String sessionId,
    Map<String, dynamic>? metadata,
  }) = _SSEAgentMessageData;

  factory SSEAgentMessageData.fromJson(Map<String, dynamic> json) =>
      _$SSEAgentMessageDataFromJson(json);
}

@freezed
class SSELLMResponseStartData with _$SSELLMResponseStartData {
  const factory SSELLMResponseStartData({
    required String status,
    required String modelName,
    required Map<String, dynamic> metadata,
  }) = _SSELLMResponseStartData;

  factory SSELLMResponseStartData.fromJson(Map<String, dynamic> json) =>
      _$SSELLMResponseStartDataFromJson(json);
}

@freezed
class SSELLMResponseEndData with _$SSELLMResponseEndData {
  const factory SSELLMResponseEndData({
    required String response,
    required String status,
    required String modelName,
    required double processingTime,
    required int tokenCount,
    required Map<String, dynamic> metadata,
  }) = _SSELLMResponseEndData;

  factory SSELLMResponseEndData.fromJson(Map<String, dynamic> json) =>
      _$SSELLMResponseEndDataFromJson(json);
}

@freezed
class SSELLMResponseErrorData with _$SSELLMResponseErrorData {
  const factory SSELLMResponseErrorData({
    required String error,
    required String errorCode,
    required String status,
    required Map<String, dynamic> metadata,
  }) = _SSELLMResponseErrorData;

  factory SSELLMResponseErrorData.fromJson(Map<String, dynamic> json) =>
      _$SSELLMResponseErrorDataFromJson(json);
}

@freezed
class SSEAgentAssignedData with _$SSEAgentAssignedData {
  const factory SSEAgentAssignedData({
    required int agentId,
    required String agentName,
  }) = _SSEAgentAssignedData;

  factory SSEAgentAssignedData.fromJson(Map<String, dynamic> json) =>
      _$SSEAgentAssignedDataFromJson(json);
}

@freezed
class SSEConversationStatusChangeData with _$SSEConversationStatusChangeData {
  const factory SSEConversationStatusChangeData({
    required String oldStatus,
    required String newStatus,
    required int changedBy,
  }) = _SSEConversationStatusChangeData;

  factory SSEConversationStatusChangeData.fromJson(Map<String, dynamic> json) =>
      _$SSEConversationStatusChangeDataFromJson(json);
}

@freezed
class SSETypingData with _$SSETypingData {
  const factory SSETypingData({
    required String status,
    required TypingBy typingBy,
  }) = _SSETypingData;

  factory SSETypingData.fromJson(Map<String, dynamic> json) =>
      _$SSETypingDataFromJson(json);
}

enum TypingBy {
  @JsonValue('ai')
  ai,
  @JsonValue('agent')
  agent,
  @JsonValue('user')
  user,
}

@freezed
class TypingIndicator with _$TypingIndicator {
  const factory TypingIndicator({
    required bool isTyping,
    required TypingBy typingBy,
  }) = _TypingIndicator;

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);
}