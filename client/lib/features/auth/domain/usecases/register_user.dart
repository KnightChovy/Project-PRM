import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Use case: đăng ký tài khoản mới.
/// Trả về [AuthSession] vì server phát token ngay khi tạo tài khoản thành công.
class RegisterUser implements UseCase<AuthSession, RegisterParams> {
  final AuthRepository repository;
  const RegisterUser(this.repository);

  @override
  Future<Either<Failure, AuthSession>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      verificationCode: params.verificationCode,
      phone: params.phone,
    );
  }
}

/// Tham số đầu vào cho [RegisterUser].
class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;

  /// Mã OTP 6 chữ số người dùng nhận qua email (từ use case `SendOtp`).
  final String verificationCode;
  final String? phone;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.verificationCode,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, verificationCode, phone];
}
