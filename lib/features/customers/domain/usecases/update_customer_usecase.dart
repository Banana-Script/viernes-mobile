import '../../../../core/errors/exceptions.dart';
import '../repositories/customer_repository.dart';

/// Update Customer Use Case
///
/// Updates an existing customer's information.
class UpdateCustomerUseCase {
  final CustomerRepository _repository;

  UpdateCustomerUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [userId]: The user ID of the customer to update
  /// - [data]: Map containing the fields to update
  ///
  /// Throws:
  /// - [ValidationException] if input parameters are invalid
  Future<void> call({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final errors = <String, List<String>>{};

    if (userId <= 0) {
      errors['userId'] = ['User ID must be a positive integer'];
    }

    if (data.isEmpty) {
      errors['data'] = ['Update data cannot be empty'];
    } else {
      // Validate email if present
      if (data.containsKey('email') && data['email'] != null) {
        final email = data['email'] as String;
        if (!_isValidEmail(email)) {
          errors['data.email'] = ['Email format is invalid'];
        }
      }
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        'Invalid customer update parameters',
        fieldErrors: errors,
      );
    }

    await _repository.updateCustomer(
      userId: userId,
      data: data,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
