import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/auth_repository.dart';

class AuthenticateWithBiometricsUseCase {
  final AuthRepository _repository;

  AuthenticateWithBiometricsUseCase(this._repository);

  Future<Either<Failure, bool>> call() async {
    // First check if biometric authentication is enabled
    final isBiometricEnabled = await _repository.isBiometricEnabled();
    if (!isBiometricEnabled) {
      return const Left(PermissionFailure(message: 'Biometric authentication is not enabled'));
    }

    return await _repository.authenticateWithBiometrics();
  }
}