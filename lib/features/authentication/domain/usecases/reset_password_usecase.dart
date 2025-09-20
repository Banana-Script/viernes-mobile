import 'package:dartz/dartz.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<Either<AuthFailure, void>> call({
    required String email,
  }) async {
    // Basic email validation
    if (email.isEmpty || !email.contains('@')) {
      return const Left(AuthFailure(
        message: 'Please enter a valid email address',
        code: 'invalid-email',
        type: AuthFailureType.invalidCredentials,
      ));
    }

    return await _authRepository.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }
}