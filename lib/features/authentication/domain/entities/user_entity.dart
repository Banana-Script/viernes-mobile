import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? name,
    String? photoUrl,
    @Default(false) bool isEmailVerified,
    @Default(true) bool isAvailable,
    String? organizationId,
    String? role,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserEntity;

  const UserEntity._();

  String get displayName => name ?? email.split('@').first;

  bool get hasCompletedProfile => name != null && name!.isNotEmpty;
}