import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_result_entity.dart';
import 'user_model.dart';

class AuthResultModel extends AuthResultEntity {
  const AuthResultModel({
    required super.user,
    required super.idToken,
    super.refreshToken,
  });

  factory AuthResultModel.fromFirebaseUserCredential(
    UserCredential credential,
    String idToken,
  ) {
    return AuthResultModel(
      user: UserModel.fromFirebaseUser(credential.user!),
      idToken: idToken,
      refreshToken: credential.user!.refreshToken,
    );
  }
}

class AuthFailureModel extends AuthFailure {
  const AuthFailureModel({
    required super.message,
    required super.code,
    required super.type,
  });

  factory AuthFailureModel.fromFirebaseAuthException(FirebaseAuthException e) {
    AuthFailureType type;
    String message;

    switch (e.code) {
      case 'user-not-found':
        type = AuthFailureType.userNotFound;
        message = 'No user found with this email address.';
        break;
      case 'wrong-password':
      case 'invalid-credential':
        type = AuthFailureType.invalidCredentials;
        message = 'Invalid email or password.';
        break;
      case 'email-already-in-use':
        type = AuthFailureType.emailAlreadyInUse;
        message = 'An account already exists with this email address.';
        break;
      case 'weak-password':
        type = AuthFailureType.weakPassword;
        message = 'The password is too weak.';
        break;
      case 'user-disabled':
        type = AuthFailureType.userDisabled;
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        type = AuthFailureType.tooManyRequests;
        message = 'Too many failed attempts. Please try again later.';
        break;
      case 'network-request-failed':
        type = AuthFailureType.network;
        message = 'Network error. Please check your connection.';
        break;
      default:
        type = AuthFailureType.unknown;
        message = e.message ?? 'An unknown error occurred.';
    }

    return AuthFailureModel(
      message: message,
      code: e.code,
      type: type,
    );
  }

  factory AuthFailureModel.fromException(Exception e) {
    return AuthFailureModel(
      message: e.toString(),
      code: 'unknown',
      type: AuthFailureType.unknown,
    );
  }

  factory AuthFailureModel.network(String message) {
    return AuthFailureModel(
      message: message,
      code: 'network-error',
      type: AuthFailureType.network,
    );
  }

  factory AuthFailureModel.server(String message) {
    return AuthFailureModel(
      message: message,
      code: 'server-error',
      type: AuthFailureType.server,
    );
  }
}