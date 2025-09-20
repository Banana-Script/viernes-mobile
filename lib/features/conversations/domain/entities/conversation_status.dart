import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_status.freezed.dart';
part 'conversation_status.g.dart';

@freezed
class ConversationStatus with _$ConversationStatus {
  const factory ConversationStatus({
    required int id,
    required String valueDefinition,
    required String description,
    required String active,
    String? validationType,
    required int definitionTypeId,
    required ConversationDefinitionType definitionType,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ConversationStatus;

  factory ConversationStatus.fromJson(Map<String, dynamic> json) =>
      _$ConversationStatusFromJson(json);
}

@freezed
class ConversationDefinitionType with _$ConversationDefinitionType {
  const factory ConversationDefinitionType({
    required int id,
    required String definitionType,
    required String description,
    required String active,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ConversationDefinitionType;

  factory ConversationDefinitionType.fromJson(Map<String, dynamic> json) =>
      _$ConversationDefinitionTypeFromJson(json);
}