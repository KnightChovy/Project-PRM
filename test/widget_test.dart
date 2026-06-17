// Basic smoke test for SmartStay app.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_stay_ai/main.dart';

void main() {
  testWidgets('App boots to loading screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartStayApp());

    // Logo brand hiển thị trên màn hình khởi động.
    expect(find.text('SmartStay'), findsOneWidget);

    // Chờ qua thời gian splash để timer điều hướng kích hoạt,
    // tránh cảnh báo "Timer is still pending".
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
