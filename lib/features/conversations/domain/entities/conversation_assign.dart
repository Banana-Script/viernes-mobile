import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_assign.freezed.dart';
part 'conversation_assign.g.dart';

@freezed
class ConversationAssign with _$ConversationAssign {
  const factory ConversationAssign({
    required int id,
    required int userId,
    required ConversationAssignUser user,
    required int conversationId,
    required DateTime createdAt,
  }) = _ConversationAssign;

  factory ConversationAssign.fromJson(Map<String, dynamic> json) =>
      _$ConversationAssignFromJson(json);
}

@freezed
class ConversationAssignUser with _$ConversationAssignUser {
  const factory ConversationAssignUser({
    required int id,
    required String fullname,
    required String email,
  }) = _ConversationAssignUser;

  factory ConversationAssignUser.fromJson(Map<String, dynamic> json) =>
      _$ConversationAssignUserFromJson(json);
}