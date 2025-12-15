class OrganizationEntity {
  final int id;
  final String? uuid;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  // Consumption fields - Messages
  final int? totalMessageCount;
  final int? currentMessageCount;

  // Consumption fields - Minutes
  final double? totalMinutesPerMonth;
  final double? totalMinutesRecharged;
  final double? currentMinutesCount;
  final double? currentMinutesRecharged;

  const OrganizationEntity({
    required this.id,
    this.uuid,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.totalMessageCount,
    this.currentMessageCount,
    this.totalMinutesPerMonth,
    this.totalMinutesRecharged,
    this.currentMinutesCount,
    this.currentMinutesRecharged,
  });

  // Computed properties for consumption
  int get remainingMessages =>
      (totalMessageCount ?? 0) - (currentMessageCount ?? 0);

  double get totalMinutes =>
      (totalMinutesPerMonth ?? 0) + (totalMinutesRecharged ?? 0);

  double get consumedMinutes => currentMinutesCount ?? 0;

  double get remainingMinutes => totalMinutes - consumedMinutes;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrganizationEntity &&
        other.id == id &&
        other.uuid == uuid &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.address == address &&
        other.totalMessageCount == totalMessageCount &&
        other.currentMessageCount == currentMessageCount &&
        other.totalMinutesPerMonth == totalMinutesPerMonth &&
        other.totalMinutesRecharged == totalMinutesRecharged &&
        other.currentMinutesCount == currentMinutesCount &&
        other.currentMinutesRecharged == currentMinutesRecharged;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uuid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        address.hashCode ^
        totalMessageCount.hashCode ^
        currentMessageCount.hashCode ^
        totalMinutesPerMonth.hashCode ^
        totalMinutesRecharged.hashCode ^
        currentMinutesCount.hashCode ^
        currentMinutesRecharged.hashCode;
  }

  @override
  String toString() {
    return 'OrganizationEntity(id: $id, uuid: $uuid, name: $name, email: $email, phone: $phone, address: $address, totalMessageCount: $totalMessageCount, currentMessageCount: $currentMessageCount)';
  }
}
