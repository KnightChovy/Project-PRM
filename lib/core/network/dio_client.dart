import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';

/// Bọc [Dio] lại một chỗ. Tầng Data chỉ gọi `client.dio`, không tự tạo Dio.
/// Sau này token/tenant header sẽ được gắn tập trung qua Interceptor ở đây.
class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
}
