import '../entities/customer_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetCustomerSummaryUseCase {
  final DashboardRepository _repository;

  GetCustomerSummaryUseCase(this._repository);

  Future<CustomerSummary> call() async {
    return await _repository.getCustomerSummary();
  }
}