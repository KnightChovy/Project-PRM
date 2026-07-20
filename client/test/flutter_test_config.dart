import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Chạy tự động trước MỌI test trong thư mục này (quy ước của flutter_test).
///
/// `DioClient` đọc `BASE_URL` từ `.env`, mà test không nạp file thật — thiếu nó
/// thì bất kỳ test nào chạm tới DI/network đều ném StateError. Nạp sẵn một giá
/// trị giả ở đây để từng file test không phải tự lo.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  dotenv.testLoad(fileInput: 'BASE_URL=https://api.test.local/v1');
  await testMain();
}
