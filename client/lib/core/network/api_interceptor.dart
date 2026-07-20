import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Gắn Authorization + tenant header tập trung cho MỌI request.
/// Feature/DataSource không tự dựng header xác thực.
class ApiInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  ApiInterceptor(this.tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = tokenStorage.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    final tenantId = tokenStorage.tenantId;
    if (tenantId != null) options.headers['X-Tenant-Id'] = tenantId;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token hết hạn/không hợp lệ — xoá token cục bộ.
      // Việc gọi lại /auth/refresh-tokens và điều hướng về màn login
      // được xử lý ở tầng Data/Presentation (AuthRepositoryImpl/AuthNotifier).
      tokenStorage.clear();
    }
    handler.next(err);
  }
}
