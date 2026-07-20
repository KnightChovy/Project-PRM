import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/auth/domain/entities/auth_tokens.dart';
import 'package:smart_stay_ai/features/auth/domain/entities/user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/forgot_password.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/login_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/logout_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/refresh_tokens.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/register_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/reset_password.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/send_otp.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/send_verification_email.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/verify_email.dart';

/// Các trạng thái có thể có của một thao tác xác thực.
enum AuthStatus { initial, loading, success, error }

/// Quản lý trạng thái cho tính năng auth bằng [ChangeNotifier].
/// Notifier CHỈ gọi UseCase, không gọi thẳng Repository hay API.
/// Dùng `flutter/foundation` (không import widget) để giữ tầng này gọn.
class AuthNotifier extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final SendOtp sendOtpUseCase;
  final RefreshTokens refreshTokensUseCase;
  final ForgotPassword forgotPasswordUseCase;
  final ResetPassword resetPasswordUseCase;
  final SendVerificationEmail sendVerificationEmailUseCase;
  final VerifyEmail verifyEmailUseCase;

  AuthNotifier({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.sendOtpUseCase,
    required this.refreshTokensUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.sendVerificationEmailUseCase,
    required this.verifyEmailUseCase,
  });

  // ---- Trạng thái đăng nhập/đăng ký chính ----
  AuthStatus status = AuthStatus.initial;
  User? user;
  AuthTokens? tokens;
  String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => tokens != null;

  // ---- Trạng thái dùng chung cho các thao tác phụ (OTP, quên/đổi mật khẩu, xác minh email) ----
  AuthStatus actionStatus = AuthStatus.initial;
  String? actionErrorMessage;

  bool get isActionLoading => actionStatus == AuthStatus.loading;

  Future<void> login({required String email, required String password}) async {
    _setLoading();
    final result = await loginUser(
      LoginParams(email: email, password: password),
    );
    result.fold(_onFailure, (session) {
      status = AuthStatus.success;
      user = session.user;
      tokens = session.tokens;
    });
    notifyListeners();
  }

  /// [verificationCode]: mã OTP 6 chữ số lấy từ [sendOtp].
  /// Server trả kèm token nên đăng ký xong là đã đăng nhập.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String verificationCode,
    String? phone,
  }) async {
    _setLoading();
    final result = await registerUser(
      RegisterParams(
        name: name,
        email: email,
        password: password,
        verificationCode: verificationCode,
        phone: phone,
      ),
    );
    result.fold(_onFailure, (session) {
      status = AuthStatus.success;
      user = session.user;
      tokens = session.tokens;
    });
    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading();
    final result = await logoutUser(const NoParams());
    result.fold(_onFailure, (_) {
      status = AuthStatus.initial;
      user = null;
      tokens = null;
    });
    notifyListeners();
  }

  Future<void> refreshTokens() async {
    final result = await refreshTokensUseCase(const NoParams());
    result.fold((_) {}, (t) => tokens = t);
    notifyListeners();
  }

  Future<void> sendOtp({required String email}) async {
    await _runAction(sendOtpUseCase(SendOtpParams(email: email)));
  }

  Future<void> forgotPassword({required String email}) async {
    await _runAction(forgotPasswordUseCase(ForgotPasswordParams(email: email)));
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _runAction(
      resetPasswordUseCase(
        ResetPasswordParams(token: token, newPassword: newPassword),
      ),
    );
  }

  /// Chỉ gọi được khi đã đăng nhập — server lấy user từ access token.
  Future<void> sendVerificationEmail() async {
    await _runAction(sendVerificationEmailUseCase(const NoParams()));
  }

  Future<void> verifyEmail({required String token}) async {
    await _runAction(verifyEmailUseCase(VerifyEmailParams(token: token)));
  }

  Future<void> _runAction(Future<Either<Failure, Unit>> future) async {
    actionStatus = AuthStatus.loading;
    actionErrorMessage = null;
    notifyListeners();

    final result = await future;
    result.fold((failure) {
      actionStatus = AuthStatus.error;
      actionErrorMessage = failure.message;
    }, (_) => actionStatus = AuthStatus.success);
    notifyListeners();
  }

  void _setLoading() {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _onFailure(Failure failure) {
    status = AuthStatus.error;
    errorMessage = failure.message;
  }
}
