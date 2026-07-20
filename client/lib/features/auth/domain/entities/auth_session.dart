import 'package:equatable/equatable.dart';
import 'auth_tokens.dart';
import 'user.dart';

/// Kết quả đăng nhập: user hiện tại + cặp token đi kèm.
class AuthSession extends Equatable {
  final User user;
  final AuthTokens tokens;

  const AuthSession({required this.user, required this.tokens});

  @override
  List<Object?> get props => [user, tokens];
}
