class OrganizationEntity {
  final int id;
  final String? uuid;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  const OrganizationEntity({
    required this.id,
    this.uuid,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationEntity &&
        other.id == id &&
        other.uuid == uuid &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.address == address;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uuid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        address.hashCode;
  }

  @override
  String toString() {
    return 'OrganizationEntity(id: $id, uuid: $uuid, name: $name, email: $email, phone: $phone, address: $address)';
  }
}
