import '../../domain/entities/auth_tokens.dart';

/// Model = Entity + khả năng đọc/ghi JSON.
class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) =>
      AuthTokensModel(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
