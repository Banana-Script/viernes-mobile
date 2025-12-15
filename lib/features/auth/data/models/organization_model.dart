import '../../domain/entities/organization_entity.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    super.uuid,
    required super.name,
    super.email,
    super.phone,
    super.address,
    super.totalMessageCount,
    super.currentMessageCount,
    super.totalMinutesPerMonth,
    super.totalMinutesRecharged,
    super.currentMinutesCount,
    super.currentMinutesRecharged,
  });

  /// Creates an OrganizationModel from backend JSON response
  /// Backend structure from /organizations/logged/user:
  /// {
  ///   "id": 131,
  ///   "uuid": "abc-123",
  ///   "name": "Organization Name",
  ///   "email": "org@example.com",
  ///   "phone": "+1234567890",
  ///   "address": "123 Main St",
  ///   "total_message_count": 10000,
  ///   "current_message_count": 179,
  ///   "total_minutes_per_month": 1000,
  ///   "total_minutes_recharged": 1173,
  ///   "current_minutes_count": 1.72,
  ///   "current_minutes_recharged": 0,
  ///   ...
  /// }
  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] ?? 0,
      uuid: json['uuid'],
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      totalMessageCount: json['total_message_count'],
      currentMessageCount: json['current_message_count'],
      totalMinutesPerMonth: _parseDouble(json['total_minutes_per_month']),
      totalMinutesRecharged: _parseDouble(json['total_minutes_recharged']),
      currentMinutesCount: _parseDouble(json['current_minutes_count']),
      currentMinutesRecharged: _parseDouble(json['current_minutes_recharged']),
    );
  }

  /// Helper to parse double from various types (int, double, String)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'total_message_count': totalMessageCount,
      'current_message_count': currentMessageCount,
      'total_minutes_per_month': totalMinutesPerMonth,
      'total_minutes_recharged': totalMinutesRecharged,
      'current_minutes_count': currentMinutesCount,
      'current_minutes_recharged': currentMinutesRecharged,
    };
  }
}
