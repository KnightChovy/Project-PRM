import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/core/widgets/app_message_dialog.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/info_screen.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/register_screen.dart';

void main() {
  Future<void> pumpRegister(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
  }

  group('RegisterScreen', () {
    testWidgets('hiển thị tiêu đề, bước và đủ 6 ô nhập', (tester) async {
      await pumpRegister(tester);

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('STEP 1 OF 2'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      // Ô thứ 6: mã OTP mà backend bắt buộc khi đăng ký.
      expect(find.text('6-digit Verification Code'), findsOneWidget);
      expect(find.text('SEND CODE'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('chưa tick điều khoản thì không điều hướng', (tester) async {
      await pumpRegister(tester);

      await tester.tap(find.text('CREATE ACCOUNT'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Vẫn ở màn đăng ký vì checkbox chưa được tick.
      expect(find.byType(InfoScreen), findsNothing);
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets(
      'thiếu thông tin bắt buộc thì không gọi đăng ký hoặc điều hướng',
      (tester) async {
        await pumpRegister(tester);

        await tester.ensureVisible(find.byType(Checkbox));
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.ensureVisible(find.text('CREATE ACCOUNT'));
        await tester.tap(find.text('CREATE ACCOUNT'));
        await tester.pumpAndSettle();

        expect(find.byType(InfoScreen), findsNothing);
        expect(find.byType(RegisterScreen), findsOneWidget);
        // Lỗi giờ hiện bằng AppMessageDialog thay cho SnackBar.
        expect(find.byType(AppMessageDialog), findsOneWidget);
        expect(find.text('Missing information'), findsOneWidget);
        expect(
          find.text('Please complete all required fields.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('nhập mật khẩu không khớp thì báo lỗi bằng dialog', (
      tester,
    ) async {
      await pumpRegister(tester);

      await tester.enterText(find.byType(TextField).at(0), 'Alex Rivera');
      await tester.enterText(find.byType(TextField).at(1), 'alex@example.com');
      await tester.enterText(find.byType(TextField).at(3), 'Password1');
      await tester.enterText(find.byType(TextField).at(4), 'Password2');

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(find.text('CREATE ACCOUNT'));
      await tester.tap(find.text('CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.byType(InfoScreen), findsNothing);
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
