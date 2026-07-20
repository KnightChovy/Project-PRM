import 'package:equatable/equatable.dart';

/// Cặp token JWT trả về sau khi login/refresh — thuần Dart, KHÔNG có fromJson/toJson.
class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
