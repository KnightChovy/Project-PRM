import '../../domain/entities/auth_tokens.dart';

/// Model = Entity + khả năng đọc/ghi JSON.
///
/// Backend trả token ở dạng LỒNG (xem `tokenService.generateAuthTokens`):
/// `{ "access": { "token", "expires" }, "refresh": { "token", "expires" } }`.
/// Dùng chung cho `/auth/login`, `/auth/register` (field `tokens`)
/// và `/auth/refresh-tokens` (trả thẳng object này ở gốc response).
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final access = json['access'] as Map<String, dynamic>;
    final refresh = json['refresh'] as Map<String, dynamic>;
    return AuthTokensModel(
      accessToken: access['token'] as String,
      refreshToken: refresh['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'access': {'token': accessToken},
    'refresh': {'token': refreshToken},
  };
}
