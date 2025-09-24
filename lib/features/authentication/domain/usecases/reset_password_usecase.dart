import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Either<Failure, void>> call(String email) async {
    final trimmedEmail = email.trim().toLowerCase();

    // Basic email validation
    if (trimmedEmail.isEmpty) {
      return const Left(ValidationFailure(message: 'Email is required'));
    }

    if (!_isValidEmail(trimmedEmail)) {
      return const Left(ValidationFailure(message: 'Please enter a valid email address'));
    }

    return await _repository.sendPasswordResetEmail(trimmedEmail);
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    return emailRegExp.hasMatch(email);
  }
}