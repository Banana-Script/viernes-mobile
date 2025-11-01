import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<UserEntity> call(String uid) async {
    if (uid.isEmpty) {
      throw Exception('User ID cannot be empty');
    }

    return await _repository.getUserProfile(uid);
  }
}
