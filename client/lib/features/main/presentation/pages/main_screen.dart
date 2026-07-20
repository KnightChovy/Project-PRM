import 'package:flutter/material.dart';
// Đổi bởi BinhKhiem: tab Bookings dùng bản nâng cấp (3 tab + Cancel/Review).
// Bản cũ my_booking_page.dart của Phat vẫn được giữ nguyên trong repo.
import 'package:smart_stay_ai/features/booking/presentation/pages/my_bookings_view_page.dart';
// Đổi bởi BinhKhiem: tab Chatbot dùng màn AI Assistant.
import 'package:smart_stay_ai/features/assistant/presentation/pages/assistant_page.dart';
import 'package:smart_stay_ai/features/home/presentation/pages/home_page.dart';
import 'package:smart_stay_ai/features/main/presentation/widgets/main_bottom_nav.dart';
import 'package:smart_stay_ai/features/profile/presentation/pages/profile_page.dart';
import 'package:smart_stay_ai/features/wishlist/presentation/pages/wishlist_page.dart';

/// Màn hình "vỏ" sau khi đăng nhập: chứa thanh điều hướng đáy + 5 tab.
/// Dùng [IndexedStack] để giữ nguyên trạng thái từng tab khi chuyển qua lại.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  /// Tab mở sẵn khi vào màn (vd 2 = My Booking sau khi đặt phòng xong).
  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index = widget.initialIndex;

  static const _pages = <Widget>[
    HomePage(),
    WishlistPage(),
    MyBookingsViewPage(),
    AssistantPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
