import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case: yêu cầu đặt lại mật khẩu (gửi email/otp reset).
class ForgotPassword implements UseCase<Unit, ForgotPasswordParams> {
  final AuthRepository repository;
  const ForgotPassword(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ForgotPasswordParams params) {
    return repository.forgotPassword(email: params.email);
  }
}

class ForgotPasswordParams extends Equatable {
  final String email;
  const ForgotPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}
