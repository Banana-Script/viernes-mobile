import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  final AuthRepository _repository;

  LoginWithEmailUseCase(this._repository);

  Future<Either<Failure, AuthResultEntity>> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }
}