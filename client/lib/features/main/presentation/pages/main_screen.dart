import 'package:flutter/material.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/core/widgets/sign_in_required_sheet.dart';
// Đổi bởi BinhKhiem: tab Bookings dùng bản nâng cấp (3 tab + Cancel/Review).
// Bản cũ my_booking_page.dart của Phat vẫn được giữ nguyên trong repo.
import 'package:smart_stay_ai/features/booking/presentation/pages/my_bookings_view_page.dart';
// Đổi bởi BinhKhiem: tab Chatbot dùng màn AI Assistant.
import 'package:smart_stay_ai/features/assistant/presentation/pages/assistant_page.dart';
import 'package:smart_stay_ai/features/home/presentation/pages/home_page.dart';
import 'package:smart_stay_ai/features/main/presentation/widgets/main_bottom_nav.dart';
import 'package:smart_stay_ai/features/profile/presentation/pages/profile_page.dart';
import 'package:smart_stay_ai/features/wishlist/presentation/pages/wishlist_page.dart';

/// Màn hình "vỏ" chứa thanh điều hướng đáy + 5 tab.
/// Dùng [IndexedStack] để giữ nguyên trạng thái từng tab khi chuyển qua lại.
///
/// Khách vãng lai vẫn xem được Home và chat AI; Wishlist / My Booking / Profile
/// gắn với tài khoản nên chạm vào sẽ mời đăng nhập.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  /// Tab mở sẵn khi vào màn (vd 2 = My Booking sau khi đặt phòng xong).
  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index = widget.initialIndex;

  /// Tab yêu cầu đăng nhập (theo thứ tự của thanh điều hướng đáy).
  static const _authRequiredTabs = {1, 2, 4};

  static const _tabMessages = {
    1: 'Lưu khách sạn yêu thích vào tài khoản của bạn.',
    2: 'Xem và quản lý các chuyến đi bạn đã đặt.',
    4: 'Quản lý hồ sơ và cài đặt tài khoản.',
  };

  /// Tab đã từng mở — dùng để dựng LƯỜI.
  ///
  /// [IndexedStack] dựng mọi con ngay lập tức, nghĩa là vừa vào Home là Profile,
  /// My Booking và Assistant đồng loạt gọi API cho những tab người dùng còn
  /// chưa nhìn tới. Chỉ dựng tab đã ghé để đỡ tốn dữ liệu di động và tránh một
  /// loạt request lỗi cùng lúc khi phiên có vấn đề.
  late final Set<int> _visited = {widget.initialIndex};

  Future<void> _onTabTapped(int index) async {
    if (index == _index) return;

    if (_authRequiredTabs.contains(index) && !sl<AppSession>().isSignedIn) {
      await showSignInRequiredSheet(
        context,
        message: _tabMessages[index] ?? 'Tính năng này cần tài khoản.',
      );
      // Không chuyển tab: khách ở lại đúng chỗ đang xem.
      return;
    }

    setState(() {
      _visited.add(index);
      _index = index;
    });
  }

  Widget _buildTab(int index) {
    // Chưa ghé thì chưa dựng — giữ chỗ bằng widget rỗng.
    if (!_visited.contains(index)) return const SizedBox.shrink();
    return switch (index) {
      0 => const HomePage(),
      1 => const WishlistPage(),
      2 => const MyBookingsViewPage(),
      3 => const AssistantPage(),
      _ => const ProfilePage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (var i = 0; i < 5; i++) _buildTab(i)],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _index,
        onTap: _onTabTapped,
      ),
    );
  }
}
