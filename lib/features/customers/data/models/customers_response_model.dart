import '../../domain/entities/customer_filters.dart';
import 'customer_model.dart';

/// Customers Response Model
///
/// Model for paginated customers API response.
class CustomersResponseModel extends CustomersResponse {
  const CustomersResponseModel({
    required super.totalCount,
    required super.totalPages,
    required super.currentPage,
    required super.pageSize,
    required super.customers,
  });

  /// Create from JSON
  factory CustomersResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomersResponseModel(
      totalCount: json['total_count'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      customers: json['customers'] != null
          ? (json['customers'] as List)
              .map((c) => CustomerModel.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'total_pages': totalPages,
      'current_page': currentPage,
      'page_size': pageSize,
      'customers': customers.map((c) => (c as CustomerModel).toJson()).toList(),
    };
  }

  /// Get customers as CustomerModel list
  List<CustomerModel> get customerModels {
    return customers.cast<CustomerModel>();
  }
}
