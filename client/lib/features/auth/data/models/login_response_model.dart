import 'auth_tokens_model.dart';
import 'user_model.dart';

/// DTO thô của response `/auth/login` (và `/auth/refresh-tokens` cho phần token).
/// Chỉ tồn tại ở tầng Data — không lộ ra Domain (repository map sang [AuthSession]).
class LoginResponseModel {
  final UserModel user;
  final AuthTokensModel tokens;

  const LoginResponseModel({required this.user, required this.tokens});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        tokens: AuthTokensModel.fromJson(json['tokens'] as Map<String, dynamic>),
      );
}
