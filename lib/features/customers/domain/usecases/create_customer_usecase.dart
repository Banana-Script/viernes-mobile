import '../../../../core/errors/exceptions.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Create Customer Use Case
///
/// Creates a new customer in the system.
class CreateCustomerUseCase {
  final CustomerRepository _repository;

  CreateCustomerUseCase(this._repository);

  /// Execute the use case
  ///
  /// Parameters:
  /// - [roleId]: The role ID for the customer
  /// - [statusId]: The status ID for the customer
  /// - [userData]: Map containing user data (name, email, phone, etc.)
  ///
  /// Throws:
  /// - [ValidationException] if input parameters are invalid
  Future<CustomerEntity> call({
    required int roleId,
    required int statusId,
    required Map<String, dynamic> userData,
  }) async {
    // Validate all parameters
    final errors = <String, List<String>>{};

    if (roleId <= 0) {
      errors['roleId'] = ['Role ID must be a positive integer'];
    }

    if (statusId <= 0) {
      errors['statusId'] = ['Status ID must be a positive integer'];
    }

    if (userData.isEmpty) {
      errors['userData'] = ['User data cannot be empty'];
    } else {
      // Validate user data fields
      if (!userData.containsKey('name') || (userData['name'] as String?)?.isEmpty == true) {
        errors['userData.name'] = ['Name is required'];
      }

      if (!userData.containsKey('email') || (userData['email'] as String?)?.isEmpty == true) {
        errors['userData.email'] = ['Email is required'];
      } else {
        final email = userData['email'] as String;
        if (!_isValidEmail(email)) {
          errors['userData.email'] = ['Email format is invalid'];
        }
      }
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        'Invalid customer creation parameters',
        fieldErrors: errors,
      );
    }

    return await _repository.createCustomer(
      roleId: roleId,
      statusId: statusId,
      userData: userData,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
