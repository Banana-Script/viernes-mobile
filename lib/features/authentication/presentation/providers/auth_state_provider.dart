import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    UserEntity? user,
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
    @Default(false) bool isBiometricEnabled,
    @Default(false) bool isBiometricAvailable,
    String? error,
  }) = _AuthState;

  const AuthState._();

  bool get isAuthenticated => user != null;
  bool get hasError => error != null;
  bool get canUseBiometric => isBiometricEnabled && isBiometricAvailable;
}