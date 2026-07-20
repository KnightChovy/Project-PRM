// Basic smoke test for SmartStay app + password validation unit test.

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/features/profile/presentation/pages/change_password_page.dart';
import 'package:smart_stay_ai/main.dart';

import 'helpers/test_dependencies.dart';

void main() {
  setUpAll(setUpTestDependencies);

  testWidgets('App boots to loading screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartStayApp());

    // Logo brand hiển thị trên màn hình khởi động.
    expect(find.text('SmartStay'), findsOneWidget);

    // Chờ qua thời gian splash để timer điều hướng kích hoạt,
    // tránh cảnh báo "Timer is still pending".
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  test('validateNewPassword enforces all rules', () {
    expect(validateNewPassword('short'), isNotNull); // too short
    expect(validateNewPassword('alllowercase1!'), isNotNull); // no uppercase
    expect(validateNewPassword('NoNumber!!'), isNotNull); // no digit
    expect(validateNewPassword('NoSpecial1'), isNotNull); // no special char
    expect(validateNewPassword('Strong1!pass'), isNull); // valid
  });
}
