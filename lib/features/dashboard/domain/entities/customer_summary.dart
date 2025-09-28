class CustomerSummary {
  final int totalCustomers;
  final int activeCustomers;
  final int newCustomers;
  final double retentionRate;

  const CustomerSummary({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomers,
    required this.retentionRate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerSummary &&
        other.totalCustomers == totalCustomers &&
        other.activeCustomers == activeCustomers &&
        other.newCustomers == newCustomers &&
        other.retentionRate == retentionRate;
  }

  @override
  int get hashCode {
    return totalCustomers.hashCode ^
        activeCustomers.hashCode ^
        newCustomers.hashCode ^
        retentionRate.hashCode;
  }

  @override
  String toString() {
    return 'CustomerSummary(totalCustomers: $totalCustomers, activeCustomers: $activeCustomers, newCustomers: $newCustomers, retentionRate: $retentionRate)';
  }
}