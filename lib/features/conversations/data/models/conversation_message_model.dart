import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversation_message.dart';

part 'conversation_message_model.freezed.dart';
part 'conversation_message_model.g.dart';

@freezed
class ConversationMessageModel with _$ConversationMessageModel {
  const factory ConversationMessageModel({
    required int id,
    @JsonKey(name: 'parent_conversation_id') required int parentConversationId,
    required String message,
    @JsonKey(name: 'json_message') String? jsonMessage,
    @JsonKey(name: 'created_at') required String createdAt,
    required bool readed,
    @JsonKey(name: 'session_id') required String sessionId,
    required ConversationMessageType type,
  }) = _ConversationMessageModel;

  const ConversationMessageModel._();

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageModelFromJson(json);

  ConversationMessage toDomain() {
    return ConversationMessage(
      id: id,
      parentConversationId: parentConversationId,
      message: message,
      jsonMessage: jsonMessage,
      createdAt: DateTime.parse(createdAt),
      readed: readed,
      sessionId: sessionId,
      type: type,
    );
  }

  factory ConversationMessageModel.fromDomain(ConversationMessage message) {
    return ConversationMessageModel(
      id: message.id,
      parentConversationId: message.parentConversationId,
      message: message.message,
      jsonMessage: message.jsonMessage,
      createdAt: message.createdAt.toIso8601String(),
      readed: message.readed,
      sessionId: message.sessionId,
      type: message.type,
    );
  }
}

@freezed
class ConversationMessagesResponseModel with _$ConversationMessagesResponseModel {
  const factory ConversationMessagesResponseModel({
    required List<ConversationMessageModel> conversation,
  }) = _ConversationMessagesResponseModel;

  const ConversationMessagesResponseModel._();

  factory ConversationMessagesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessagesResponseModelFromJson(json);

  ConversationMessagesResponse toDomain() {
    return ConversationMessagesResponse(
      conversation: conversation.map((m) => m.toDomain()).toList(),
    );
  }
}

@freezed
class SendMessageRequestModel with _$SendMessageRequestModel {
  const factory SendMessageRequestModel({
    required String message,
    @JsonKey(name: 'session_id') required String sessionId,
  }) = _SendMessageRequestModel;

  const SendMessageRequestModel._();

  factory SendMessageRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestModelFromJson(json);

  factory SendMessageRequestModel.fromDomain(SendMessageRequest request) {
    return SendMessageRequestModel(
      message: request.message,
      sessionId: request.sessionId,
    );
  }
}

@freezed
class SendMessageResponseModel with _$SendMessageResponseModel {
  const factory SendMessageResponseModel({
    required String status,
    required int code,
    required String description,
  }) = _SendMessageResponseModel;

  const SendMessageResponseModel._();

  factory SendMessageResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendMessageResponseModelFromJson(json);

  SendMessageResponse toDomain() {
    return SendMessageResponse(
      status: status,
      code: code,
      description: description,
    );
  }
}