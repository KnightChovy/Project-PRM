import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Bản GIẢ LẬP của [AuthRemoteDataSource] — dùng khi chưa có backend.
/// Trả về user giả thay vì gọi API thật.
///
/// Tài khoản demo:  email: demo@smartstay.com  ·  mật khẩu: 123456
class AuthMockRemoteDataSource implements AuthRemoteDataSource {
  static const demoEmail = 'demo@smartstay.com';
  static const demoPassword = '123456';

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Giả vờ gọi mạng ~0.6s cho giống thật.
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.trim() == demoEmail && password == demoPassword) {
      return const UserModel(
        id: 'u1',
        name: 'Alex Rivera',
        email: demoEmail,
      );
    }
    throw const ServerException(message: 'Email hoặc mật khẩu không đúng');
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
}
