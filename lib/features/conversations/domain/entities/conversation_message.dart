import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_message.freezed.dart';
part 'conversation_message.g.dart';

@freezed
class ConversationMessage with _$ConversationMessage {
  const factory ConversationMessage({
    required int id,
    required int parentConversationId,
    required String message,
    String? jsonMessage,
    required DateTime createdAt,
    required bool readed,
    required String sessionId,
    required ConversationMessageType type,
  }) = _ConversationMessage;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageFromJson(json);
}

enum ConversationMessageType {
  @JsonValue('user')
  user,
  @JsonValue('gpt')
  gpt,
  @JsonValue('tool')
  tool,
  @JsonValue('tool_call')
  toolCall,
}

@freezed
class ConversationMessagesResponse with _$ConversationMessagesResponse {
  const factory ConversationMessagesResponse({
    required List<ConversationMessage> conversation,
  }) = _ConversationMessagesResponse;

  factory ConversationMessagesResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessagesResponseFromJson(json);
}

@freezed
class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String message,
    required String sessionId,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}

@freezed
class SendMessageResponse with _$SendMessageResponse {
  const factory SendMessageResponse({
    required String status,
    required int code,
    required String description,
  }) = _SendMessageResponse;

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$SendMessageResponseFromJson(json);
}