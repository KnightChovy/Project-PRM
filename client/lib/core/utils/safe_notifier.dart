import 'package:flutter/foundation.dart';

/// Cho phép gọi thông báo thay đổi mà không sợ notifier đã bị dispose.
///
/// Các notifier đăng ký kiểu `registerFactory` được provider sở hữu và dispose
/// khi rời màn. Nếu người dùng bấm back trong lúc request còn đang chạy thì
/// đoạn code sau `await` vẫn gọi `notifyListeners()` trên một object đã chết và
/// Flutter ném "A ChangeNotifier was used after being disposed".
///
/// Widget vẫn phải tự kiểm tra `mounted` trước khi đụng tới BuildContext —
/// mixin này chỉ bảo vệ phần state bên trong notifier.
mixin SafeNotifier on ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Như [notifyListeners] nhưng bỏ qua nếu notifier đã bị dispose.
  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }
}
