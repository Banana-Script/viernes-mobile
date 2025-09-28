import '../../domain/entities/customer_summary.dart';

class CustomerSummaryModel extends CustomerSummary {
  const CustomerSummaryModel({
    required super.totalCustomers,
    required super.activeCustomers,
    required super.newCustomers,
    required super.retentionRate,
  });

  factory CustomerSummaryModel.fromJson(Map<String, dynamic> json) {
    return CustomerSummaryModel(
      totalCustomers: json['total_customers'] ?? 0,
      activeCustomers: json['active_customers'] ?? 0,
      newCustomers: json['new_customers'] ?? 0,
      retentionRate: (json['retention_rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_customers': totalCustomers,
      'active_customers': activeCustomers,
      'new_customers': newCustomers,
      'retention_rate': retentionRate,
    };
  }

  CustomerSummary toEntity() {
    return CustomerSummary(
      totalCustomers: totalCustomers,
      activeCustomers: activeCustomers,
      newCustomers: newCustomers,
      retentionRate: retentionRate,
    );
  }
}