import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  // Store the last fetched user to get the user ID for availability changes
  UserEntity? _currentUser;

  UserRepositoryImpl({required UserRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> getUserProfile() async {
    try {
      final user = await _remoteDataSource.getUserProfile();
      _currentUser = user; // Cache the user for later use
      return user;
    } catch (e) {
      // Re-throw the exception to be handled by the use case/provider
      rethrow;
    }
  }

  @override
  Future<void> changeAgentAvailability(bool isAvailable) async {
    try {
      // Get the user ID from the current user
      final userId = _currentUser?.databaseId;

      if (userId == null) {
        throw Exception('User ID not available. Please fetch user profile first.');
      }

      // Call the remote data source with the user ID
      await _remoteDataSource.changeAgentAvailability(userId, isAvailable);
    } catch (e) {
      // Re-throw the exception to be handled by the use case/provider
      rethrow;
    }
  }
}
