import 'package:dartz/dartz.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository _authRepository;

  LoginWithGoogleUseCase(this._authRepository);

  Future<Either<AuthFailure, AuthResultEntity>> call() async {
    return await _authRepository.signInWithGoogle();
  }
}