import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/core/router/app_router.dart';
import 'package:smart_stay_ai/features/main/presentation/pages/main_screen.dart';
import 'package:smart_stay_ai/features/onboarding/presentation/pages/introduction_screen.dart';

import 'helpers/test_dependencies.dart';

void main() {
  // Nhấn Skip sẽ mở trang chủ, mà cây widget ở đó lấy notifier qua sl<>().
  setUpAll(setUpTestDependencies);

  Future<void> pumpIntro(WidgetTester tester) async {
    await pumpWithRouter(
      tester,
      initialLocation: AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: const IntroductionScreen(),
        AppRoutes.home: const MainScreen(),
      },
    );
  }

  group('IntroductionScreen', () {
    testWidgets('hiển thị trang đầu tiên với tiêu đề và badge', (tester) async {
      await pumpIntro(tester);

      expect(find.text('AI Finds Your Perfect Stay'), findsOneWidget);
      expect(find.text('98% Match Found'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('nhấn Next chuyển sang trang kế tiếp', (tester) async {
      await pumpIntro(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Tailored Just For You'), findsOneWidget);
    });

    testWidgets('đến trang cuối thì nút đổi thành Start', (tester) async {
      await pumpIntro(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Effortless Reservations'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    // Khách phải xem được app trước khi bị hỏi tài khoản: Skip vào thẳng trang
    // chủ chứ không đẩy sang màn đăng nhập như trước.
    testWidgets('nhấn Skip vào thẳng trang chủ, không bắt đăng nhập', (
      tester,
    ) async {
      await pumpIntro(tester);

      await tester.tap(find.text('Skip'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(MainScreen), findsOneWidget);
    });
  });
}
