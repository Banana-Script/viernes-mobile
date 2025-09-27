import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

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
    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email');
    }

    return await repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}