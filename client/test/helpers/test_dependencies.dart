import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/features/profile/presentation/providers/profile_notifier.dart';

/// Dựng service locator cho widget test.
///
/// Các màn hình lấy notifier bằng `sl<X>()` ngay trong `build()`, nên nếu chưa
/// đăng ký DI thì widget test ném "GetIt: Object/factory ... is not registered".
/// Ngoài ra [initDependencies] gọi `SharedPreferences.getInstance()` — trong môi
/// trường test không có plugin thật nên phải nạp giá trị giả trước, không thì
/// dính `MissingPluginException`.
Future<void> setUpTestDependencies() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await sl.reset();
  await initDependencies();
}

/// Pump một màn hình KÈM go_router thật.
///
/// Các màn điều hướng bằng `context.go()` / `context.push()`; nếu chỉ pump
/// `MaterialApp(home: X)` thì không có GoRouter tổ tiên nên thao tác điều hướng
/// im lặng không xảy ra và test tìm màn đích sẽ fail.
///
/// [routes] map đường dẫn → widget, [initialLocation] là màn hình cần test.
Future<void> pumpWithRouter(
  WidgetTester tester, {
  required String initialLocation,
  required Map<String, Widget> routes,
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      for (final entry in routes.entries)
        GoRoute(path: entry.key, builder: (_, _) => entry.value),
    ],
  );
  addTearDown(router.dispose);

  // App thật provide AppSession + ProfileNotifier ở gốc (xem main.dart); test
  // phải dựng y hệt, không thì màn nào dùng Consumer của chúng sẽ ném
  // ProviderNotFoundException.
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSession>.value(value: sl<AppSession>()),
        ChangeNotifierProvider<ProfileNotifier>.value(
          value: sl<ProfileNotifier>(),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}
