import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';

/// Đổi [DioException] thành Exception của app, giữ lại **message do server trả
/// về** thay vì message kỹ thuật của Dio.
///
/// Backend trả lỗi dạng `{ "code": 400, "message": "Đã hết phòng đêm ..." }`
/// và message đã là tiếng Việt cho end-user, nên không được nuốt mất nó.
Never throwApiException(DioException e, {required String fallback}) {
  final response = e.response;

  // Không có response = chưa chạm tới server (mất mạng, timeout, DNS...).
  if (response == null) {
    throw NetworkException(
      message: switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'Kết nối tới máy chủ quá lâu, vui lòng thử lại',
        _ => 'Không có kết nối mạng',
      },
    );
  }

  final message = _extractMessage(response.data) ?? fallback;

  throw switch (response.statusCode) {
    400 => ValidationException(message: message),
    401 => UnauthorizedException(message: message),
    404 => NotFoundException(message: message),
    _ => ServerException(message: message),
  };
}

/// Lấy `message` trong body lỗi. Body có thể không phải Map (HTML từ proxy,
/// chuỗi rỗng...) nên phải dò cẩn thận.
String? _extractMessage(Object? data) {
  if (data is! Map) return null;
  final message = data['message'];
  if (message is String && message.trim().isNotEmpty) return message;
  return null;
}
