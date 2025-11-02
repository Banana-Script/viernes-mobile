/// Customer Detail Entity
///
/// Domain entity representing detailed customer information.
/// This entity is used in the customer detail view.
class CustomerDetailEntity {
  final int id;
  final String fullname;
  final int? age;
  final String? occupation;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastInteraction;
  final String? sessionId;
  final String? firebaseUid;
  final String? identification;
  final int? verifyingIdentification;
  final String? verificationCode;
  final int verified;
  final int? interestsNotificationsRequested;
  final int? interestsNotificationsActivated;
  final int? interestsNotificationsFrequency;
  final String? instance;
  final List<dynamic> segments;

  const CustomerDetailEntity({
    required this.id,
    required this.fullname,
    this.age,
    this.occupation,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.lastInteraction,
    this.sessionId,
    this.firebaseUid,
    this.identification,
    this.verifyingIdentification,
    this.verificationCode,
    required this.verified,
    this.interestsNotificationsRequested,
    this.interestsNotificationsActivated,
    this.interestsNotificationsFrequency,
    this.instance,
    this.segments = const [],
  });

  /// Check if customer is verified
  bool get isVerified => verified == 1;
}
