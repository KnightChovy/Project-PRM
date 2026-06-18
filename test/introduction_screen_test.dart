import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/login_screen.dart';
import 'package:smart_stay_ai/features/onboarding/presentation/pages/introduction_screen.dart';

void main() {
  Future<void> pumpIntro(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: IntroductionScreen()));
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

    testWidgets('nhấn Skip điều hướng sang màn Login', (tester) async {
      await pumpIntro(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}
