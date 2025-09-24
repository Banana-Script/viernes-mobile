import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth_result_entity.dart';
import 'user_model.dart';

part 'auth_result_model.freezed.dart';
part 'auth_result_model.g.dart';

@freezed
class AuthResultModel with _$AuthResultModel {
  const factory AuthResultModel({
    required UserModel user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'is_new_user') @Default(false) bool isNewUser,
  }) = _AuthResultModel;

  const AuthResultModel._();

  factory AuthResultModel.fromJson(Map<String, dynamic> json) => _$AuthResultModelFromJson(json);

  AuthResultEntity toEntity() {
    return AuthResultEntity(
      user: user.toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      isNewUser: isNewUser,
    );
  }

  static AuthResultModel fromEntity(AuthResultEntity entity) {
    return AuthResultModel(
      user: UserModel.fromEntity(entity.user),
      accessToken: entity.accessToken,
      refreshToken: entity.refreshToken,
      expiresAt: entity.expiresAt,
      isNewUser: entity.isNewUser,
    );
  }
}