import '../../../../core/errors/exceptions.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Get Customer By ID Use Case
///
/// Retrieves a single customer by their user ID.
/// Uses the /users/{userId} endpoint which includes all optional fields.
class GetCustomerByIdUseCase {
  final CustomerRepository _repository;

  GetCustomerByIdUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [userId]: The user ID of the customer to retrieve
  ///
  /// Throws:
  /// - [ValidationException] if userId is invalid
  Future<CustomerEntity> call(int userId) async {
    if (userId <= 0) {
      throw ValidationException(
        'Invalid user ID',
        fieldErrors: {
          'userId': ['User ID must be a positive integer']
        },
      );
    }

    return await _repository.getCustomerById(userId);
  }
}
