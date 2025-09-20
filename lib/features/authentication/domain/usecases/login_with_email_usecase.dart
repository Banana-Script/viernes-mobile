import 'package:dartz/dartz.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository _authRepository;

  LoginWithEmailUseCase(this._authRepository);

  Future<Either<AuthFailure, AuthResultEntity>> call({
    required String email,
    required String password,
  }) async {
    // Basic email validation
    if (email.isEmpty || !email.contains('@')) {
      return const Left(AuthFailure(
        message: 'Please enter a valid email address',
        code: 'invalid-email',
        type: AuthFailureType.invalidCredentials,
      ));
    }

    // Basic password validation
    if (password.isEmpty || password.length < 6) {
      return const Left(AuthFailure(
        message: 'Password must be at least 6 characters long',
        code: 'invalid-password',
        type: AuthFailureType.invalidCredentials,
      ));
    }

    return await _authRepository.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}