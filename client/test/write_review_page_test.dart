import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/features/review/presentation/pages/write_review_page.dart';

void main() {
  // DI thật nhưng dùng datasource mock trong RAM nên an toàn cho widget test.
  setUp(() async {
    await sl.reset();
    await initDependencies();
  });

  testWidgets('WriteReviewPage hiển thị tiêu đề, tên khách sạn và nút Submit',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WriteReviewPage(
          args: WriteReviewArgs(
            hotelName: 'Amanoi Resort',
            location: 'Vinh Hy Bay, Ninh Thuan',
            imageUrl: 'https://example.com/a.jpg',
          ),
        ),
      ),
    );

    expect(find.text('Write Review'), findsOneWidget);
    expect(find.text('Amanoi Resort'), findsOneWidget);
    expect(find.text('OVERALL RATING'), findsOneWidget);
    expect(find.text('Cleanliness'), findsOneWidget);

    // Nút Submit nằm cuối ListView → cuộn tới rồi mới kiểm tra.
    await tester.scrollUntilVisible(
      find.text('Submit Review'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Submit Review'), findsOneWidget);
  });
}
