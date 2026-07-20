/// Exception CHỈ được ném ra ở tầng Data (DataSource).
/// RepositoryImpl sẽ bắt nó và đổi thành [Failure] trước khi đẩy lên trên.
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

/// 400 — request không hợp lệ theo nghiệp vụ (hết phòng, quá sức chứa,
/// chưa có SĐT...). `message` từ server đã là tiếng Việt, hiển thị thẳng được.
class ValidationException implements Exception {
  final String message;
  const ValidationException({required this.message});
}

/// 401 — thiếu token hoặc token hết hạn.
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({required this.message});
}

/// 404 — không tìm thấy tài nguyên.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException({required this.message});
}

/// Không nhận được phản hồi nào (mất mạng, timeout).
class NetworkException implements Exception {
  final String message;
  const NetworkException({required this.message});
}
