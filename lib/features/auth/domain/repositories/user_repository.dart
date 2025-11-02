import '../entities/user_entity.dart';

abstract class UserRepository {
  /// Fetches the complete user profile from the backend
  /// Uses the Firebase token to identify the user
  Future<UserEntity> getUserProfile();

  /// Changes the agent availability status
  /// isAvailable: true for active, false for inactive
  Future<void> changeAgentAvailability(bool isAvailable);
}
