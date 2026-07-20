import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/profile/presentation/providers/profile_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Nạp .env trước — DI đọc BASE_URL từ đây.
  await initDependencies(); // Khởi tạo DI trước khi chạy app.
  runApp(const SmartStayApp());
}

class SmartStayApp extends StatelessWidget {
  const SmartStayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Hai notifier này là trạng thái toàn app (phiên đăng nhập + hồ sơ) nên
    // provide MỘT LẦN ở gốc: bất kỳ màn nào cũng đọc được mà không phải tự bọc
    // provider riêng. Dùng `.value` vì cả hai là singleton trong DI — để
    // provider tự tạo thì nó sẽ dispose mất khi cây widget bị dựng lại.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSession>.value(value: sl<AppSession>()),
        ChangeNotifierProvider<ProfileNotifier>.value(
          value: sl<ProfileNotifier>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'SmartStay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
