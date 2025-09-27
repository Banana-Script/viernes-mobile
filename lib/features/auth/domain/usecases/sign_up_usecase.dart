import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }
    if (confirmPassword.isEmpty) {
      throw Exception('Please confirm your password');
    }
    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    return await repository.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}