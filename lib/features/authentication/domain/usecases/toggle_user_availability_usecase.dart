import 'package:dartz/dartz.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class ToggleUserAvailabilityUseCase {
  final AuthRepository _authRepository;

  ToggleUserAvailabilityUseCase(this._authRepository);

  Future<Either<AuthFailure, void>> call({
    required String databaseId,
    required bool available,
  }) async {
    if (databaseId.isEmpty) {
      return const Left(AuthFailure(
        message: 'Invalid user database ID',
        code: 'invalid-database-id',
        type: AuthFailureType.invalidCredentials,
      ));
    }

    return await _authRepository.toggleUserAvailability(
      databaseId: databaseId,
      available: available,
    );
  }
}