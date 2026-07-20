import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case: gửi mã OTP xác minh về email.
class SendOtp implements UseCase<Unit, SendOtpParams> {
  final AuthRepository repository;
  const SendOtp(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SendOtpParams params) {
    return repository.sendOtp(email: params.email);
  }
}

class SendOtpParams extends Equatable {
  final String email;
  const SendOtpParams({required this.email});

  @override
  List<Object?> get props => [email];
}
