import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/auth_tokens_model.dart';

/// Nơi gọi API thật. Khi lỗi thì NÉM Exception (không trả Either).
abstract interface class AuthRemoteDataSource {
  Future<void> sendOtp({required String email});

  /// Backend bắt buộc [verificationCode] (6 chữ số, lấy từ [sendOtp])
  /// và trả về `{ user, tokens }` — user đã được đánh dấu verified sẵn.
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String verificationCode,
    String? phone,
  });

  Future<AuthResponseModel> login({
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

  /// Không nhận email: backend lấy user từ Bearer token (route có `auth()`).
  Future<void> sendVerificationEmail();

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
      throw ServerException(
        message: _messageOf(e, 'Unable to send the verification code.'),
      );
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String verificationCode,
    String? phone,
  }) async {
    try {
      final res = await client.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'verificationCode': verificationCode,
          // Field optional: chỉ gửi khi người dùng thực sự nhập.
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Unable to create your account.'),
      );
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      // API trả về { "user": {...}, "tokens": {...} } ở gốc response.
      return AuthResponseModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(message: _messageOf(e, 'Unable to sign you in.'));
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
      throw ServerException(message: _messageOf(e, 'Unable to sign you out.'));
    }
  }

  @override
  Future<AuthTokensModel> refreshTokens({required String refreshToken}) async {
    try {
      final res = await client.dio.post(
        ApiConstants.refreshTokens,
        data: {'refreshToken': refreshToken},
      );
      // Endpoint này trả thẳng { access: {...}, refresh: {...} }.
      return AuthTokensModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Your session could not be renewed.'),
      );
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
      throw ServerException(
        message: _messageOf(e, 'Unable to start the password reset.'),
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      // token đi ở QUERY, mật khẩu mới nằm ở body dưới tên `password`.
      await client.dio.post(
        ApiConstants.resetPassword,
        queryParameters: {'token': token},
        data: {'password': newPassword},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Unable to reset your password.'),
      );
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      // Không có body: user được suy ra từ Bearer token do ApiInterceptor gắn.
      await client.dio.post(ApiConstants.sendVerificationEmail);
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Unable to send the verification email.'),
      );
    }
  }

  @override
  Future<void> verifyEmail({required String token}) async {
    try {
      // token đi ở QUERY, không có body.
      await client.dio.post(
        ApiConstants.verifyEmail,
        queryParameters: {'token': token},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: _messageOf(e, 'Unable to verify your email.'),
      );
    }
  }

  /// Backend trả lỗi dạng `{ code, message }` — CHỈ lấy `message` đó.
  ///
  /// Không dùng `e.message` của Dio vì nó lộ chi tiết kỹ thuật cho người dùng
  /// ("Http status error [401]", URL, stack...). Khi không có message từ API
  /// thì dùng câu mô tả sẵn của từng hành động.
  String _messageOf(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }
    // Không chạm được tới server (mất mạng, timeout, sai baseUrl...).
    if (e.response == null) {
      return 'Cannot reach the server. Check your connection and try again.';
    }
    return fallback;
  }
}
