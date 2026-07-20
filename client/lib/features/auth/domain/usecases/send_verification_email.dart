import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case: gửi lại email xác minh tài khoản.
class SendVerificationEmail
    implements UseCase<Unit, SendVerificationEmailParams> {
  final AuthRepository repository;
  const SendVerificationEmail(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendVerificationEmailParams params) {
    return repository.sendVerificationEmail(email: params.email);
  }
}

class SendVerificationEmailParams extends Equatable {
  final String email;
  const SendVerificationEmailParams({required this.email});

  @override
  List<Object?> get props => [email];
}
