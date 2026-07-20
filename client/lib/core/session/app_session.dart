import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';

/// Trạng thái đăng nhập dùng chung cho toàn app.
///
/// Trước đây không có chỗ nào làm chủ vòng đời phiên: token được lưu vào
/// SharedPreferences nhưng không ai đọc lúc khởi động, router không chặn màn
/// hình cần đăng nhập, và khi logout thì các notifier singleton vẫn giữ nguyên
/// dữ liệu của người dùng cũ. [AppSession] là chỗ duy nhất trả lời câu hỏi
/// "đang đăng nhập chưa?" và là chỗ duy nhất dọn dẹp khi đăng xuất.
class AppSession extends ChangeNotifier {
  final TokenStorage tokenStorage;

  /// Các hàm dọn state của từng notifier/kho dữ liệu singleton.
  ///
  /// Đăng ký từ tầng DI để [AppSession] không phải phụ thuộc ngược vào feature.
  final List<void Function()> _resetHandlers = [];

  AppSession(this.tokenStorage);

  /// Có token trong máy nghĩa là phiên còn dùng được: access token hết hạn thì
  /// [ApiInterceptor] tự làm mới bằng refresh token.
  bool get isSignedIn => tokenStorage.refreshToken != null;

  void addResetHandler(void Function() handler) => _resetHandlers.add(handler);

  /// Gọi sau khi đăng nhập/đăng ký thành công để router tính lại redirect.
  void onSignedIn() => notifyListeners();

  /// Dọn sạch dữ liệu của người dùng vừa thoát.
  ///
  /// BẮT BUỘC gọi khi logout: các notifier là lazy singleton sống suốt vòng đời
  /// tiến trình, không dọn thì người đăng nhập kế tiếp trên cùng máy sẽ nhìn
  /// thấy hồ sơ, danh sách booking và toàn bộ lịch sử chat AI của người trước.
  void onSignedOut() {
    for (final reset in _resetHandlers) {
      reset();
    }
    notifyListeners();
  }
}
