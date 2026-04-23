// =====================================================
// User Model - Freezed
// =====================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String phone,
    required String fullName,
    String? profilePhotoUrl,
    DateTime? birthDate,
    String? region,
    String? city,
    String? aboutMe,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    @Default(true) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

// Auth State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.authenticated(UserModel user) = Authenticated;
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.loading() = Loading;
  const factory AuthState.error(String message) = AuthError;
}