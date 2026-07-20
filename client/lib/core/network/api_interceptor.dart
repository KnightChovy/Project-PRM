import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Gắn Authorization + tenant header tập trung cho MỌI request, và tự động
/// làm mới phiên khi access token hết hạn.
///
/// Access token của backend chỉ sống 30 phút. Trước đây interceptor gặp 401 là
/// xoá sạch token rồi thôi — nghĩa là sau 30 phút mọi màn hình đều hỏng và
/// refresh token (còn hạn nhiều ngày) cũng bị xoá luôn nên không cứu được.
/// Giờ 401 sẽ kích hoạt một lượt refresh rồi CHẠY LẠI request ban đầu.
class ApiInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  /// Làm mới phiên và lưu cặp token mới. Trả `true` nếu thành công.
  ///
  /// Truyền vào dưới dạng callback thay vì gọi thẳng AuthRepository để tránh
  /// phụ thuộc vòng: repository cần DioClient, mà DioClient lại tạo ra chính
  /// interceptor này.
  final Future<bool> Function() refreshSession;

  ApiInterceptor(this.tokenStorage, {required this.refreshSession});

  /// Dio đang gắn interceptor này — [DioClient] gán ngay sau khi khởi tạo.
  /// Cần để chạy lại request cũ mà vẫn đi qua onRequest (gắn token mới).
  late final Dio dio;

  /// Đánh dấu request đã được thử lại một lần, tránh lặp vô hạn nếu lần chạy
  /// lại vẫn trả 401.
  static const _retriedFlag = '__retried_after_refresh';

  /// Đảm bảo N request cùng dính 401 chỉ tạo ĐÚNG MỘT lượt refresh.
  ///
  /// Không có chốt này thì màn hình gọi song song nhiều API sẽ bắn nhiều lượt
  /// refresh cùng lúc; server xoay vòng refresh token và coi token cũ bị dùng
  /// lại là dấu hiệu bị đánh cắp → thu hồi TẤT CẢ phiên của người dùng.
  Future<bool>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    final tenantId = tokenStorage.tenantId;
    if (tenantId != null) options.headers['X-Tenant-Id'] = tenantId;
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isExpiredSession = err.response?.statusCode == 401;

    // 401 từ chính các endpoint auth KHÔNG phải là phiên hết hạn: đó là sai
    // mật khẩu, refresh token hỏng... Nếu vẫn xoá token ở đây thì chỉ cần gõ
    // sai mật khẩu một lần là mất luôn phiên đang đăng nhập hợp lệ.
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;

    if (!isExpiredSession ||
        alreadyRetried ||
        _isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    final renewed = await _refreshOnce();
    if (!renewed) {
      // Hết đường cứu — lúc này mới được phép dọn phiên.
      await tokenStorage.clear();
      return handler.next(err);
    }

    try {
      handler.resolve(await _retry(err.requestOptions));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// `/auth/login`, `/auth/register`, `/auth/refresh-tokens`...
  bool _isAuthEndpoint(String path) => path.startsWith('/auth/');

  Future<bool> _refreshOnce() {
    return _refreshing ??= refreshSession().whenComplete(() {
      _refreshing = null;
    });
  }

  /// Bắn lại request cũ với access token vừa được làm mới.
  Future<Response<dynamic>> _retry(RequestOptions options) {
    // Đi qua Dio gốc để onRequest tự gắn access token mới.
    options.extra = {...options.extra, _retriedFlag: true};
    return dio.fetch(options);
  }
}
