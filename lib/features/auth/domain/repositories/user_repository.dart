import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Fetches the complete user profile from the backend
  Future<UserEntity> getUserProfile(String uid);
}
