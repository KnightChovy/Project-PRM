/// Địa chỉ API & các đường dẫn endpoint dùng chung.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:5000/v1';

  static const String sendOtp = '/auth/send-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshTokens = '/auth/refresh-tokens';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String sendVerificationEmail = '/auth/send-verification-email';
  static const String verifyEmail = '/auth/verify-email';
}
