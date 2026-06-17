import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_stay_ai/screens/register_screen.dart';
import 'package:smart_stay_ai/screens/info_screen.dart';

void main() {
  Future<void> pumpRegister(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
  }

  group('RegisterScreen', () {
    testWidgets('hiển thị tiêu đề, bước và đủ 5 ô nhập', (tester) async {
      await pumpRegister(tester);

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('STEP 1 OF 2'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('chưa tick điều khoản thì không điều hướng', (tester) async {
      await pumpRegister(tester);

      await tester.tap(find.text('CREATE ACCOUNT'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Vẫn ở màn đăng ký vì checkbox chưa được tick.
      expect(find.byType(InfoScreen), findsNothing);
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('tick điều khoản rồi tạo tài khoản -> sang màn Info',
        (tester) async {
      await pumpRegister(tester);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.ensureVisible(find.text('CREATE ACCOUNT'));
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      expect(find.byType(InfoScreen), findsOneWidget);
      expect(find.text('Step 2 of 2'), findsOneWidget);
    });

    testWidgets('hai nút con mắt độc lập nhau', (tester) async {
      await pumpRegister(tester);

      // Password + Confirm Password -> 2 icon ẩn.
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
