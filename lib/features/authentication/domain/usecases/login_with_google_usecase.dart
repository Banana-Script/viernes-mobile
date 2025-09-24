import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  final AuthRepository _repository;

  LoginWithGoogleUseCase(this._repository);

  Future<Either<Failure, AuthResultEntity>> call() async {
    return await _repository.signInWithGoogle();
  }
}