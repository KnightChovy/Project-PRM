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
