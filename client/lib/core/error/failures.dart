import 'package:equatable/equatable.dart';

/// Lỗi "sạch" dùng chung — thứ DUY NHẤT được phép đi lên tầng Domain/Presentation.
/// (Exception chỉ tồn tại ở tầng Data, xem [exceptions.dart].)
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Lỗi từ server (API trả về 4xx/5xx, sai dữ liệu...).
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Lỗi mạng (không có internet).
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Lỗi xác thực (sai mật khẩu, hết hạn token...).
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Request sai theo luật nghiệp vụ (400). `message` lấy nguyên từ server —
/// đã là tiếng Việt nên Presentation hiển thị thẳng cho user.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// Không tìm thấy tài nguyên (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}
