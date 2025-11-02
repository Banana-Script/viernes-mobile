import '../../../../core/errors/exceptions.dart';
import '../repositories/customer_repository.dart';

/// Delete Customer Use Case
///
/// Deletes a customer from the system.
class DeleteCustomerUseCase {
  final CustomerRepository _repository;

  DeleteCustomerUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [customerId]: The ID of the customer to delete
  ///
  /// Throws:
  /// - [ValidationException] if customerId is invalid
  Future<void> call(int customerId) async {
    if (customerId <= 0) {
      throw ValidationException(
        'Invalid customer ID',
        fieldErrors: {
          'customerId': ['Customer ID must be a positive integer']
        },
      );
    }

    await _repository.deleteCustomer(customerId);
  }
}
