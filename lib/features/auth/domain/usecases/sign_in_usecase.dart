import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/utils/validators.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Use centralized validator
    final emailError = Validators.email(email);
    if (emailError != null) {
      throw Exception(emailError);
    }

    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}