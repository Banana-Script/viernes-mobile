import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([List properties = const <dynamic>[]]) : super();

  String get message;

  @override
  List<Object> get props => [];
}

// General failures
class ServerFailure extends Failure {
  @override
  final String message;

  const ServerFailure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  @override
  final String message;

  const NetworkFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  @override
  final String message;

  const CacheFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ValidationFailure extends Failure {
  @override
  final String message;

  const ValidationFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Authentication failures
class AuthenticationFailure extends Failure {
  @override
  final String message;

  const AuthenticationFailure(this.message);

  @override
  List<Object> get props => [message];
}

class UnauthorizedFailure extends Failure {
  @override
  final String message;

  const UnauthorizedFailure(this.message);

  @override
  List<Object> get props => [message];
}

// Firebase specific failures
class FirebaseFailure extends Failure {
  @override
  final String message;
  final String? code;

  const FirebaseFailure(this.message, {this.code});

  @override
  List<Object> get props => [message, code ?? ''];
}