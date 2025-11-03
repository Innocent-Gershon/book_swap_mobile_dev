import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(false) bool isEmailVerified,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) = _UserEntity;
}
