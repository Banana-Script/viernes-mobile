import 'package:dartz/dartz.dart';
import '../entities/auth_result_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<Either<AuthFailure, AuthResultEntity>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Validate input
    final validationResult = _validateInput(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    if (validationResult != null) {
      return Left(validationResult);
    }

    // Step 1: Register user in the external API first (like the web app)
    final apiRegistrationResult = await _authRepository.registerUserInAPI(
      email: email.trim().toLowerCase(),
      password: password,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
    );

    if (apiRegistrationResult.isLeft()) {
      return apiRegistrationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected success in failed branch'),
      );
    }

    // Step 2: Create Firebase user for authentication
    final firebaseResult = await _authRepository.signUpWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    return firebaseResult.fold(
      (failure) => Left(failure),
      (authResult) => Right(authResult),
    );
  }

  AuthFailure? _validateInput({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    // Email validation
    if (email.isEmpty || !email.contains('@')) {
      return const AuthFailure(
        message: 'Please enter a valid email address',
        code: 'invalid-email',
        type: AuthFailureType.invalidCredentials,
      );
    }

    // Password validation
    if (password.isEmpty || password.length < 6) {
      return const AuthFailure(
        message: 'Password must be at least 6 characters long',
        code: 'weak-password',
        type: AuthFailureType.weakPassword,
      );
    }

    // Name validation
    if (firstName.trim().isEmpty) {
      return const AuthFailure(
        message: 'Please enter your first name',
        code: 'invalid-first-name',
        type: AuthFailureType.invalidCredentials,
      );
    }

    if (lastName.trim().isEmpty) {
      return const AuthFailure(
        message: 'Please enter your last name',
        code: 'invalid-last-name',
        type: AuthFailureType.invalidCredentials,
      );
    }

    return null;
  }
}