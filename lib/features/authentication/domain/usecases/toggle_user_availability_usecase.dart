import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class ToggleUserAvailabilityUseCase {
  final AuthRepository _repository;

  ToggleUserAvailabilityUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(bool isAvailable) async {
    return await _repository.toggleUserAvailability(isAvailable);
  }
}