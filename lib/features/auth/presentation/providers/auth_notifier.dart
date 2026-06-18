import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/auth/domain/entities/user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/login_user.dart';
import 'package:smart_stay_ai/features/auth/domain/usecases/register_user.dart';

/// Các trạng thái có thể có của màn xác thực.
enum AuthStatus { initial, loading, success, error }

/// Quản lý trạng thái cho tính năng auth bằng [ChangeNotifier].
/// Notifier CHỈ gọi UseCase, không gọi thẳng Repository hay API.
/// Dùng `flutter/foundation` (không import widget) để giữ tầng này gọn.
class AuthNotifier extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthNotifier({
    required this.loginUser,
    required this.registerUser,
  });

  // ---- Trạng thái UI đọc để vẽ lại ----
  AuthStatus status = AuthStatus.initial;
  User? user;
  String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
    final result = await loginUser(
      LoginParams(email: email, password: password),
    );
    result.fold(_onFailure, _onSuccess);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    final result = await registerUser(
      RegisterParams(name: name, email: email, password: password),
    );
    result.fold(_onFailure, _onSuccess);
    notifyListeners();
  }

  void _setLoading() {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _onSuccess(User u) {
    status = AuthStatus.success;
    user = u;
  }

  void _onFailure(Failure failure) {
    status = AuthStatus.error;
    errorMessage = failure.message;
  }
}
