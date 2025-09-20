import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_user.freezed.dart';
part 'conversation_user.g.dart';

@freezed
class ConversationUser with _$ConversationUser {
  const factory ConversationUser({
    required int id,
    required String fullname,
    required int age,
    required String occupation,
    required String email,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastInteraction,
    required String sessionId,
    String? firebaseUid,
    required String identification,
    required int verifyingIdentification,
    String? verificationCode,
    required int verified,
    required int interestsNotificationsRequested,
    required int interestsNotificationsActivated,
    required int interestsNotificationsFrequency,
    required String instance,
    @Default([]) List<ConversationSegment> segments,
  }) = _ConversationUser;

  factory ConversationUser.fromJson(Map<String, dynamic> json) =>
      _$ConversationUserFromJson(json);
}

@freezed
class ConversationSegment with _$ConversationSegment {
  const factory ConversationSegment({
    required int id,
    required String segment,
    required String summary,
    required String description,
    required int organizationId,
    required int userId,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ConversationSegment;

  factory ConversationSegment.fromJson(Map<String, dynamic> json) =>
      _$ConversationSegmentFromJson(json);
}