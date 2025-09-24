import 'package:local_auth/local_auth.dart';
import '../../../../core/errors/exceptions.dart';

abstract class BiometricService {
  Future<bool> isAvailable();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> authenticate({required String reason});
  Future<bool> isDeviceSupported();
  Future<bool> canCheckBiometrics();
}

class BiometricServiceImpl implements BiometricService {
  final LocalAuthentication _localAuth;

  BiometricServiceImpl({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      throw BiometricException(message: 'Failed to check biometric availability: ${e.toString()}');
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      throw BiometricException(message: 'Failed to get available biometrics: ${e.toString()}');
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      final bool isAvailable = await this.isAvailable();
      if (!isAvailable) {
        throw const BiometricException(message: 'Biometric authentication not available');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      if (e is BiometricException) rethrow;
      throw BiometricException(message: 'Authentication failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      throw BiometricException(message: 'Failed to check device support: ${e.toString()}');
    }
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      throw BiometricException(message: 'Failed to check biometric capability: ${e.toString()}');
    }
  }
}

