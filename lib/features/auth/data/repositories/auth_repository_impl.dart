import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<UserEntity?> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Stream<UserEntity?> get authStateChanges => dataSource.authStateChanges;

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await dataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await dataSource.sendPasswordResetEmail(email: email);
  }
}