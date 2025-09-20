import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_tag.freezed.dart';
part 'conversation_tag.g.dart';

@freezed
class ConversationTag with _$ConversationTag {
  const factory ConversationTag({
    required int id,
    required String tagName,
    required int organizationId,
    required String description,
    int? modifiedById,
    int? appliedById,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ConversationTag;

  factory ConversationTag.fromJson(Map<String, dynamic> json) =>
      _$ConversationTagFromJson(json);
}