import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case: xác minh email bằng token nhận được qua [SendVerificationEmail].
class VerifyEmail implements UseCase<Unit, VerifyEmailParams> {
  final AuthRepository repository;
  const VerifyEmail(this.repository);

  @override
  Future<Either<Failure, Unit>> call(VerifyEmailParams params) {
    return repository.verifyEmail(token: params.token);
  }
}

class VerifyEmailParams extends Equatable {
  final String token;
  const VerifyEmailParams({required this.token});

  @override
  List<Object?> get props => [token];
}
