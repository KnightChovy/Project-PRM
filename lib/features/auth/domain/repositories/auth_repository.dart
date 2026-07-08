import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/auth_session.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

/// Hợp đồng (interface) cho việc xác thực.
/// Domain chỉ KHAI BÁO — tầng Data sẽ hiện thực (implement).
abstract interface class AuthRepository {
  /// Gửi mã OTP xác minh về email (vd: trước khi đăng ký/đổi mật khẩu).
  Future<Either<Failure, Unit>> sendOtp({required String email});

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Đăng nhập — trả về user + cặp token, đồng thời lưu token vào máy.
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });

  /// Đăng xuất — huỷ token trên server và xoá token đã lưu ở máy.
  Future<Either<Failure, Unit>> logout();

  /// Làm mới access token bằng refresh token đang lưu ở máy.
  Future<Either<Failure, AuthTokens>> refreshTokens();

  Future<Either<Failure, Unit>> forgotPassword({required String email});

  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, Unit>> sendVerificationEmail({
    required String email,
  });

  Future<Either<Failure, Unit>> verifyEmail({required String token});
}
