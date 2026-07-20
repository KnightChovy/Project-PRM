import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'auth_remote_data_source.dart';
import '../models/auth_tokens_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

/// Bản GIẢ LẬP của [AuthRemoteDataSource] — dùng khi chưa có backend.
/// Trả về user/token giả thay vì gọi API thật.
///
/// Tài khoản demo:  email: demo@smartstay.com  ·  mật khẩu: 123456
class AuthMockRemoteDataSource implements AuthRemoteDataSource {
  static const demoEmail = 'demo@smartstay.com';
  static const demoPassword = '123456';

  @override
  Future<void> sendOtp({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Đăng ký demo: chấp nhận mọi thông tin, trả về user vừa tạo.
    return UserModel(id: 'u-new', name: name, email: email.trim());
  }

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    // Giả vờ gọi mạng ~0.6s cho giống thật.
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim() == demoEmail && password == demoPassword) {
      return const LoginResponseModel(
        user: UserModel(id: 'u1', name: 'Alex Rivera', email: demoEmail),
        tokens: AuthTokensModel(
          accessToken: 'mock-access-token',
          refreshToken: 'mock-refresh-token',
        ),
      );
    }
    throw const ServerException(message: 'Email hoặc mật khẩu không đúng');
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<AuthTokensModel> refreshTokens({required String refreshToken}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const AuthTokensModel(
      accessToken: 'mock-access-token-renewed',
      refreshToken: 'mock-refresh-token',
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> sendVerificationEmail({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }
}
