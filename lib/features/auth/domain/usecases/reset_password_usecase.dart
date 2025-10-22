import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<void> call({required String email}) async {
    return await repository.sendPasswordResetEmail(email: email);
  }
}
