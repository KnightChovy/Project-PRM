import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case: đặt lại mật khẩu bằng token nhận được từ [ForgotPassword].
class ResetPassword implements UseCase<Unit, ResetPasswordParams> {
  final AuthRepository repository;
  const ResetPassword(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String token;
  final String newPassword;
  const ResetPasswordParams({required this.token, required this.newPassword});

  @override
  List<Object?> get props => [token, newPassword];
}
