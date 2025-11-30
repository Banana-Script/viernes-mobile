import '../../domain/entities/organization_entity.dart';

class OrganizationModel extends OrganizationEntity {
  const OrganizationModel({
    required super.id,
    super.uuid,
    required super.name,
    super.email,
    super.phone,
    super.address,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}
