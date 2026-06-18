part of 'auth_bloc.dart';

/// Các "trạng thái" mà Bloc phát ra cho UI vẽ lại.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu, chưa làm gì.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Đang gọi API, hiện vòng xoay loading.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Thành công, có thông tin [User].
class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// Thất bại, kèm thông báo lỗi.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
