import '../../../../core/errors/exceptions.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Get Customer By ID Use Case
///
/// Retrieves a single customer by their ID.
class GetCustomerByIdUseCase {
  final CustomerRepository _repository;

  GetCustomerByIdUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [customerId]: The ID of the customer to retrieve
  ///
  /// Throws:
  /// - [ValidationException] if customerId is invalid
  Future<CustomerEntity> call(int customerId) async {
    if (customerId <= 0) {
      throw ValidationException(
        'Invalid customer ID',
        fieldErrors: {
          'customerId': ['Customer ID must be a positive integer']
        },
      );
    }

    return await _repository.getCustomerById(customerId);
  }
}
