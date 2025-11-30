import '../../domain/entities/customer_detail_entity.dart';

/// Customer Detail Model
///
/// Data model for customer detail that extends the domain entity.
/// Handles JSON serialization/deserialization for detailed customer information.
class CustomerDetailModel extends CustomerDetailEntity {
  const CustomerDetailModel({
    required super.id,
    required super.fullname,
    super.age,
    super.occupation,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    super.lastInteraction,
    super.sessionId,
    super.firebaseUid,
    super.identification,
    super.verifyingIdentification,
    super.verificationCode,
    required super.verified,
    super.interestsNotificationsRequested,
    super.interestsNotificationsActivated,
    super.interestsNotificationsFrequency,
    super.instance,
    super.segments,
  });

  /// Create from JSON
  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailModel(
      id: json['id'] as int,
      fullname: json['fullname'] as String? ?? '',
      age: json['age'] as int?,
      occupation: json['occupation'] as String?,
      email: json['email'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      lastInteraction: json['last_interaction'] != null
          ? DateTime.parse(json['last_interaction'] as String)
          : null,
      sessionId: json['session_id'] as String?,
      firebaseUid: json['firebase_uid'] as String?,
      identification: json['identification'] as String?,
      verifyingIdentification: json['verifying_identification'] as int?,
      verificationCode: json['verification_code'] as String?,
      verified: json['verified'] as int? ?? 0,
      interestsNotificationsRequested: json['interests_notifications_requested'] as int?,
      interestsNotificationsActivated: json['interests_notifications_activated'] as int?,
      interestsNotificationsFrequency: json['interests_notifications_frequency'] as int?,
      instance: json['instance'] as String?,
      segments: (json['segments'] as List?)?.toList() ?? [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'age': age,
      'occupation': occupation,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_interaction': lastInteraction?.toIso8601String(),
      'session_id': sessionId,
      'firebase_uid': firebaseUid,
      'identification': identification,
      'verifying_identification': verifyingIdentification,
      'verification_code': verificationCode,
      'verified': verified,
      'interests_notifications_requested': interestsNotificationsRequested,
      'interests_notifications_activated': interestsNotificationsActivated,
      'interests_notifications_frequency': interestsNotificationsFrequency,
      'instance': instance,
      'segments': segments,
    };
  }
}
