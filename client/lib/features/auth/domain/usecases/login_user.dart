import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Use case: đăng nhập. 1 hành động = 1 class.
class LoginUser implements UseCase<AuthSession, LoginParams> {
  final AuthRepository repository;
  const LoginUser(this.repository);

  @override
  Future<Either<Failure, AuthSession>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}

/// Tham số đầu vào cho [LoginUser].
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
