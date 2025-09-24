import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_entity.dart';

part 'auth_result_entity.freezed.dart';

@freezed
class AuthResultEntity with _$AuthResultEntity {
  const factory AuthResultEntity({
    required UserEntity user,
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
    @Default(false) bool isNewUser,
  }) = _AuthResultEntity;

  const AuthResultEntity._();

  bool get isTokenExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get willExpireSoon {
    if (expiresAt == null) return false;
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return expiresAt!.isBefore(fiveMinutesFromNow);
  }
}