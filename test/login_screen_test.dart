import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/login_screen.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/register_screen.dart';

void main() {
  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
  }

  group('LoginScreen', () {
    testWidgets('hiển thị tiêu đề và các ô nhập liệu', (tester) async {
      await pumpLogin(tester);

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue your journey.'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('nhập được email và mật khẩu', (tester) async {
      await pumpLogin(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Email Address'),
        'user@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'secret123',
      );

      expect(find.text('user@test.com'), findsOneWidget);
    });

    testWidgets('nút con mắt bật/tắt ẩn mật khẩu', (tester) async {
      await pumpLogin(tester);

      // Ban đầu mật khẩu bị ẩn -> icon visibility_off.
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('nhấn Sign Up điều hướng sang màn đăng ký', (tester) async {
      await pumpLogin(tester);

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}
