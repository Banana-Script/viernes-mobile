import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class AuthResultEntity extends Equatable {
  final UserEntity user;
  final String idToken;
  final String? refreshToken;

  const AuthResultEntity({
    required this.user,
    required this.idToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [user, idToken, refreshToken];
}

class AuthFailure extends Equatable {
  final String message;
  final String code;
  final AuthFailureType type;

  const AuthFailure({
    required this.message,
    required this.code,
    required this.type,
  });

  @override
  List<Object> get props => [message, code, type];
}

enum AuthFailureType {
  network,
  server,
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  userDisabled,
  tooManyRequests,
  unknown,
}