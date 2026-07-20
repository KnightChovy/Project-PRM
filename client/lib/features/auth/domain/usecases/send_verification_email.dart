import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case: gửi lại email xác minh cho user đang đăng nhập.
/// Không cần tham số — server xác định user từ access token.
class SendVerificationEmail implements UseCase<Unit, NoParams> {
  final AuthRepository repository;
  const SendVerificationEmail(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.sendVerificationEmail();
  }
}
