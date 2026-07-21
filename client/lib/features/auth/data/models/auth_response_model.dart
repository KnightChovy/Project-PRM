import 'auth_tokens_model.dart';
import 'user_model.dart';

/// DTO thô của response `/auth/login` VÀ `/auth/register` — cả hai endpoint
/// đều trả `{ "user": {...}, "tokens": { "access": {...}, "refresh": {...} } }`.
/// Chỉ tồn tại ở tầng Data — không lộ ra Domain (repository map sang [AuthSession]).
class AuthResponseModel {
  final UserModel user;
  final AuthTokensModel tokens;

  const AuthResponseModel({required this.user, required this.tokens});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        tokens: AuthTokensModel.fromJson(
          json['tokens'] as Map<String, dynamic>,
        ),
      );
}
