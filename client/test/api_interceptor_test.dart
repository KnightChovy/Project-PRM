import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/network/api_interceptor.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';

/// Adapter giả: trả mã lỗi theo kịch bản, không đụng mạng thật.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusFor);

  /// Nhận (đường dẫn, số lần đường dẫn đó đã được gọi) → mã HTTP trả về.
  final int Function(String path, int callIndex) statusFor;

  final List<RequestOptions> requests = [];
  final Map<String, int> _counts = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final index = _counts.update(options.path, (v) => v + 1, ifAbsent: () => 0);
    final status = statusFor(options.path, index);
    return ResponseBody.fromString(
      jsonEncode({'ok': status == 200}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _buildDio(
  _FakeAdapter adapter,
  TokenStorage storage, {
  required Future<bool> Function() refreshSession,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost/v1'));
  final interceptor = ApiInterceptor(storage, refreshSession: refreshSession);
  interceptor.dio = dio;
  dio.interceptors.add(interceptor);
  dio.httpClientAdapter = adapter;
  return dio;
}

Future<TokenStorage> _storageWithTokens() async {
  SharedPreferences.setMockInitialValues({
    'auth_access_token': 'expired-access',
    'auth_refresh_token': 'valid-refresh',
  });
  return TokenStorage(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    '401 sẽ làm mới phiên rồi chạy lại request, không văng lỗi ra ngoài',
    () async {
      final storage = await _storageWithTokens();
      // Lần đầu /users/me trả 401, lần thứ hai (sau refresh) trả 200.
      final adapter = _FakeAdapter((path, i) => i == 0 ? 401 : 200);

      var refreshCount = 0;
      final dio = _buildDio(
        adapter,
        storage,
        refreshSession: () async {
          refreshCount++;
          await storage.saveTokens(
            accessToken: 'fresh-access',
            refreshToken: 'fresh-refresh',
          );
          return true;
        },
      );

      final res = await dio.get<dynamic>('/users/me');

      expect(res.statusCode, 200);
      expect(refreshCount, 1);
      expect(adapter.requests.length, 2);
      // Request chạy lại phải mang access token MỚI.
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer fresh-access',
      );
    },
  );

  test('nhiều request cùng dính 401 chỉ tạo ĐÚNG MỘT lượt refresh', () async {
    final storage = await _storageWithTokens();
    final adapter = _FakeAdapter((path, i) => i == 0 ? 401 : 200);

    var refreshCount = 0;
    final dio = _buildDio(
      adapter,
      storage,
      refreshSession: () async {
        refreshCount++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await storage.saveTokens(
          accessToken: 'fresh-access',
          refreshToken: 'fresh-refresh',
        );
        return true;
      },
    );

    await Future.wait([
      dio.get<dynamic>('/users/me'),
      dio.get<dynamic>('/notifications'),
      dio.get<dynamic>('/conversations/me'),
    ]);

    // Refresh nhiều lượt song song sẽ khiến server coi là token bị dùng lại và
    // thu hồi TOÀN BỘ phiên của người dùng.
    expect(refreshCount, 1);
  });

  test('refresh thất bại thì mới xoá token cục bộ', () async {
    final storage = await _storageWithTokens();
    final adapter = _FakeAdapter((path, i) => 401);

    final dio = _buildDio(adapter, storage, refreshSession: () async => false);

    await expectLater(
      dio.get<dynamic>('/users/me'),
      throwsA(isA<DioException>()),
    );
    expect(storage.accessToken, isNull);
    expect(storage.refreshToken, isNull);
  });

  test('401 khi đăng nhập sai mật khẩu KHÔNG được xoá phiên đang có', () async {
    final storage = await _storageWithTokens();
    final adapter = _FakeAdapter((path, i) => 401);

    var refreshCount = 0;
    final dio = _buildDio(
      adapter,
      storage,
      refreshSession: () async {
        refreshCount++;
        return true;
      },
    );

    await expectLater(
      dio.post<dynamic>('/auth/login'),
      throwsA(isA<DioException>()),
    );

    expect(refreshCount, 0, reason: 'sai mật khẩu không phải phiên hết hạn');
    expect(storage.refreshToken, 'valid-refresh');
  });

  test('request đã thử lại mà vẫn 401 thì dừng, không lặp vô hạn', () async {
    final storage = await _storageWithTokens();
    final adapter = _FakeAdapter((path, i) => 401);

    var refreshCount = 0;
    final dio = _buildDio(
      adapter,
      storage,
      refreshSession: () async {
        refreshCount++;
        return true;
      },
    );

    await expectLater(
      dio.get<dynamic>('/users/me'),
      throwsA(isA<DioException>()),
    );

    expect(refreshCount, 1);
    // Gọi lần đầu + chạy lại đúng một lần.
    expect(adapter.requests.length, 2);
  });
}
