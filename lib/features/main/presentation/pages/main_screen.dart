import 'package:flutter/material.dart';
import 'package:smart_stay_ai/core/theme/app_theme.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/my_booking_page.dart';
import 'package:smart_stay_ai/features/main/presentation/widgets/main_bottom_nav.dart';
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

  // Tạm thời các tab chưa làm là trang placeholder. Khi xong feature thì thay.
  static const _pages = <Widget>[
    _PlaceholderPage(icon: Icons.home_rounded, title: 'Home'),
    WishlistPage(),
    MyBookingPage(),
    _PlaceholderPage(icon: Icons.chat_bubble_outline, title: 'Chatbot'),
    _PlaceholderPage(icon: Icons.person_outline, title: 'Profile'),
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

/// Trang tạm cho mỗi tab — chỉ hiện icon + tên để biết đang ở đâu.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.goldLight),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đang phát triển...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
