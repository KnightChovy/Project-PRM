import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../models/auth_tokens_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

/// Nơi gọi API thật. Khi lỗi thì NÉM Exception (không trả Either).
abstract interface class AuthRemoteDataSource {
  Future<void> sendOtp({required String email});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<void> logout({required String refreshToken});

  Future<AuthTokensModel> refreshTokens({required String refreshToken});

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> sendVerificationEmail({required String email});

  Future<void> verifyEmail({required String token});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;
  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<void> sendOtp({required String email}) async {
    try {
      await client.dio.post(ApiConstants.sendOtp, data: {'email': email});
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Gửi OTP thất bại');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Đăng ký thất bại');
    }
  }

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      // Giả định API trả về { "user": {...}, "tokens": { "accessToken", "refreshToken" } }.
      return LoginResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Đăng nhập thất bại');
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await client.dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Đăng xuất thất bại');
    }
  }

  @override
  Future<AuthTokensModel> refreshTokens({required String refreshToken}) async {
    try {
      final res = await client.dio.post(
        ApiConstants.refreshTokens,
        data: {'refreshToken': refreshToken},
      );
      return AuthTokensModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Làm mới token thất bại');
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await client.dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Yêu cầu quên mật khẩu thất bại');
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await client.dio.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Đặt lại mật khẩu thất bại');
    }
  }

  @override
  Future<void> sendVerificationEmail({required String email}) async {
    try {
      await client.dio.post(
        ApiConstants.sendVerificationEmail,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Gửi email xác minh thất bại',
      );
    }
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    try {
      await client.dio.post(
        ApiConstants.verifyEmail,
        data: {'token': token},
      );
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Xác minh email thất bại');
    }
  }
}
