import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository _repository;

  GetUserProfileUseCase(this._repository);

  /// Fetches the user profile from the backend
  /// Uses the Firebase token for authentication (no UID needed)
  Future<UserEntity> call() async {
    return await _repository.getUserProfile();
  }
}
