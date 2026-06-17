import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_stay_ai/screens/info_screen.dart';
import 'package:smart_stay_ai/theme/app_theme.dart';

void main() {
  Future<void> pumpInfo(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InfoScreen()));
  }

  // Lấy màu nền của khối chip/card chứa [label] để kiểm tra trạng thái chọn.
  Color? containerColorOf(WidgetTester tester, String label) {
    final container = tester.widget<AnimatedContainer>(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(AnimatedContainer),
      ).first,
    );
    return (container.decoration as BoxDecoration).color;
  }

  group('InfoScreen', () {
    testWidgets('hiển thị các section và tiến trình bước 2/2', (tester) async {
      await pumpInfo(tester);

      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('TRAVEL STYLE'), findsOneWidget);
      expect(find.text('MUST-HAVE AMENITIES'), findsOneWidget);
      expect(find.text('BUDGET PREFERENCE'), findsOneWidget);
      expect(find.text('Complete Profile'), findsOneWidget);
    });

    testWidgets('chọn travel style mới sẽ highlight đúng chip', (tester) async {
      await pumpInfo(tester);

      // Mặc định Luxury được chọn.
      expect(containerColorOf(tester, 'Luxury'), AppColors.goldDark);
      expect(containerColorOf(tester, 'Wellness'), AppColors.surface);

      await tester.tap(find.text('Wellness'));
      await tester.pump();

      expect(containerColorOf(tester, 'Wellness'), AppColors.goldDark);
      expect(containerColorOf(tester, 'Luxury'), AppColors.surface);
    });

    testWidgets('bật/tắt được amenity', (tester) async {
      await pumpInfo(tester);

      // Fine Dining mặc định chưa chọn -> nền trắng.
      expect(containerColorOf(tester, 'Fine Dining'), AppColors.surface);

      await tester.ensureVisible(find.text('Fine Dining'));
      await tester.tap(find.text('Fine Dining'));
      await tester.pump();

      expect(containerColorOf(tester, 'Fine Dining'), AppColors.creamDark);
    });

    testWidgets('đổi ngân sách sang Ultra-Luxury', (tester) async {
      await pumpInfo(tester);

      // Premium chọn sẵn (nền trắng), Ultra-Luxury chưa.
      expect(containerColorOf(tester, 'Ultra-Luxury'), Colors.transparent);

      await tester.ensureVisible(find.text('Ultra-Luxury'));
      await tester.tap(find.text('Ultra-Luxury'));
      await tester.pump();

      expect(containerColorOf(tester, 'Ultra-Luxury'), AppColors.surface);
      expect(containerColorOf(tester, 'Premium'), Colors.transparent);
    });

    testWidgets('nhấn Complete Profile hiện SnackBar', (tester) async {
      await pumpInfo(tester);

      await tester.ensureVisible(find.text('Complete Profile'));
      await tester.tap(find.text('Complete Profile'));
      await tester.pump();

      expect(find.text('Profile completed!'), findsOneWidget);
    });
  });
}
