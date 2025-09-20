import 'package:dartz/dartz.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<Either<AuthFailure, void>> call() async {
    return await _authRepository.signOut();
  }
}