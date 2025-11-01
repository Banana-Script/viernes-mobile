import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl({required UserRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> getUserProfile(String uid) async {
    try {
      return await _remoteDataSource.getUserProfile(uid);
    } catch (e) {
      // Re-throw the exception to be handled by the use case/provider
      rethrow;
    }
  }
}
