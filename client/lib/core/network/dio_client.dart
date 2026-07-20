import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'api_interceptor.dart';
import 'token_storage.dart';

/// Bọc [Dio] lại một chỗ. Tầng Data chỉ gọi `client.dio`, không tự tạo Dio.
/// Token/tenant header được gắn tập trung qua [ApiInterceptor].
class DioClient {
  final Dio dio;

  DioClient(
    TokenStorage tokenStorage, {
    required Future<bool> Function() refreshSession,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: ApiConstants.baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
         ),
       ) {
    final interceptor = ApiInterceptor(
      tokenStorage,
      refreshSession: refreshSession,
    );
    // Interceptor cần chính Dio này để chạy lại request sau khi refresh.
    interceptor.dio = dio;
    dio.interceptors.add(interceptor);
  }
}
