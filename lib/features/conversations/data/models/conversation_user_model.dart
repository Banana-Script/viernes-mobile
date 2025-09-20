import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/conversation_user.dart';

part 'conversation_user_model.freezed.dart';
part 'conversation_user_model.g.dart';

@freezed
class ConversationUserModel with _$ConversationUserModel {
  const factory ConversationUserModel({
    required int id,
    required String fullname,
    required int age,
    required String occupation,
    required String email,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'last_interaction') required String lastInteraction,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'firebase_uid') String? firebaseUid,
    required String identification,
    @JsonKey(name: 'verifying_identification') required int verifyingIdentification,
    @JsonKey(name: 'verification_code') String? verificationCode,
    required int verified,
    @JsonKey(name: 'interests_notifications_requested') required int interestsNotificationsRequested,
    @JsonKey(name: 'interests_notifications_activated') required int interestsNotificationsActivated,
    @JsonKey(name: 'interests_notifications_frequency') required int interestsNotificationsFrequency,
    required String instance,
    @Default([]) List<ConversationSegmentModel> segments,
  }) = _ConversationUserModel;

  const ConversationUserModel._();

  factory ConversationUserModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationUserModelFromJson(json);

  ConversationUser toDomain() {
    return ConversationUser(
      id: id,
      fullname: fullname,
      age: age,
      occupation: occupation,
      email: email,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      lastInteraction: DateTime.parse(lastInteraction),
      sessionId: sessionId,
      firebaseUid: firebaseUid,
      identification: identification,
      verifyingIdentification: verifyingIdentification,
      verificationCode: verificationCode,
      verified: verified,
      interestsNotificationsRequested: interestsNotificationsRequested,
      interestsNotificationsActivated: interestsNotificationsActivated,
      interestsNotificationsFrequency: interestsNotificationsFrequency,
      instance: instance,
      segments: segments.map((s) => s.toDomain()).toList(),
    );
  }
}

@freezed
class ConversationSegmentModel with _$ConversationSegmentModel {
  const factory ConversationSegmentModel({
    required int id,
    required String segment,
    required String summary,
    required String description,
    @JsonKey(name: 'organization_id') required int organizationId,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ConversationSegmentModel;

  const ConversationSegmentModel._();

  factory ConversationSegmentModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationSegmentModelFromJson(json);

  ConversationSegment toDomain() {
    return ConversationSegment(
      id: id,
      segment: segment,
      summary: summary,
      description: description,
      organizationId: organizationId,
      userId: userId,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}