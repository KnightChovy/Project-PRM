import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_stay_ai/core/di/injection.dart';
import 'package:smart_stay_ai/core/session/app_session.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/info_screen.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/login_screen.dart';
import 'package:smart_stay_ai/features/auth/presentation/pages/register_screen.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/presentation/models/booking_draft.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/booking_confirmed_page.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/booking_details_page.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/guest_details_page.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/payment_page.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/hotel/presentation/models/hotel_filter.dart';
import 'package:smart_stay_ai/features/hotel/presentation/pages/filter_sort_page.dart';
import 'package:smart_stay_ai/features/hotel/presentation/pages/hotel_detail_page.dart';
import 'package:smart_stay_ai/features/hotel/presentation/pages/hotel_search_page.dart';
import 'package:smart_stay_ai/features/hotel/presentation/pages/map_view_page.dart';
import 'package:smart_stay_ai/features/main/presentation/pages/main_screen.dart';
import 'package:smart_stay_ai/features/review/presentation/pages/guest_reviews_page.dart';
import 'package:smart_stay_ai/features/onboarding/presentation/pages/introduction_screen.dart';
import 'package:smart_stay_ai/features/onboarding/presentation/pages/loading_screen.dart';
import 'package:smart_stay_ai/features/rooms/domain/entities/room.dart';
import 'package:smart_stay_ai/features/rooms/presentation/pages/room_detail_page.dart';
import 'package:smart_stay_ai/features/rooms/presentation/pages/room_list_page.dart';
// ---- Thêm bởi BinhKhiem (feat: myBooking/detail/cancel/review/AI) ----
import 'package:smart_stay_ai/features/assistant/presentation/pages/assistant_page.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/booking_detail_view_page.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/cancel_booking_page.dart';
import 'package:smart_stay_ai/features/booking/presentation/pages/my_bookings_view_page.dart';
import 'package:smart_stay_ai/features/review/presentation/pages/write_review_page.dart';

/// Tên (đường dẫn) các route — khai báo 1 chỗ để tránh gõ chuỗi lung tung.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const info = '/info';
  static const home = '/home';
  static const hotelSearch = '/hotel-search';
  static const filterSort = '/filter-sort';
  static const mapView = '/map-view';
  static const guestReviews = '/guest-reviews';
  static const hotelDetail = '/hotel-detail';
  static const rooms = '/rooms';
  static const roomDetail = '/room-detail';
  static const bookingDetails = '/booking-details';
  static const guestDetails = '/guest-details';
  static const payment = '/payment';
  static const bookingConfirmed = '/booking-confirmed';
  // ---- Thêm bởi BinhKhiem ----
  static const myBookingsView = '/my-bookings';
  static const bookingDetailView = '/booking-detail-view';
  static const cancelBooking = '/cancel-booking';
  static const writeReview = '/write-review';
  static const assistant = '/assistant';

  /// Các màn khách vãng lai xem được.
  ///
  /// Đây là app đặt phòng: bắt đăng nhập mới cho xem khách sạn thì mất khách.
  /// Nên cho duyệt thoải mái (trang chủ, tìm kiếm, chi tiết khách sạn/phòng,
  /// và chat AI — backend cũng cho khách chat với hạn mức riêng), chỉ chặn ở
  /// các hành động gắn với tài khoản.
  ///
  /// Danh sách TRẮNG chứ không phải danh sách đen: route mới thêm sau này mặc
  /// định được bảo vệ. Quên khai báo thì cùng lắm bắt đăng nhập thừa, chứ
  /// không để lọt màn hình cần bảo vệ.
  static const publicRoutes = <String>{
    splash,
    onboarding,
    login,
    register,
    info,
    home,
    hotelSearch,
    filterSort,
    mapView,
    guestReviews,
    hotelDetail,
    rooms,
    roomDetail,
    assistant,
  };
}

/// Cấu hình điều hướng tập trung. Đây là NƠI DUY NHẤT biết tất cả các page,
/// nhờ vậy các feature không phải import page của nhau.
///
/// Dữ liệu phức tạp (Hotel, Room, BookingDraft...) được truyền qua `extra`.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  // Tính lại redirect mỗi khi phiên đổi (đăng nhập / đăng xuất / hết hạn).
  refreshListenable: sl<AppSession>(),
  redirect: (context, state) {
    final session = sl<AppSession>();
    final isPublic = AppRoutes.publicRoutes.contains(state.matchedLocation);

    // Chưa đăng nhập mà mở màn cần tài khoản (deep link, hoặc phiên vừa bị thu
    // hồi) → đẩy về login. Đây là lưới an toàn cuối cùng; luồng thường thì UI
    // đã mời đăng nhập bằng bottom sheet trước khi tới được đây.
    if (!session.isSignedIn && !isPublic) return AppRoutes.login;

    // Đã đăng nhập thì không cho quay lại màn đăng nhập/đăng ký nữa.
    if (session.isSignedIn &&
        (state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register)) {
      return AppRoutes.home;
    }
    return null;
  },
  routes: [
    // Mở app / đổi màn chính: hiệu ứng mờ dần (fade).
    GoRoute(
      path: AppRoutes.splash,
      pageBuilder: (_, state) => _fade(state, const LoadingScreen()),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (_, state) => _fade(state, const IntroductionScreen()),
    ),
    GoRoute(
      path: AppRoutes.login,
      pageBuilder: (_, state) => _fade(state, const LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.home,
      // extra (nếu có) là index tab muốn mở sẵn (vd 2 = My Booking).
      pageBuilder: (_, state) =>
          _fade(state, MainScreen(initialIndex: state.extra as int? ?? 0)),
    ),
    // Đi sâu vào chi tiết: hiệu ứng trượt từ phải sang (slide).
    GoRoute(
      path: AppRoutes.register,
      pageBuilder: (_, state) => _slide(state, const RegisterScreen()),
    ),
    GoRoute(
      path: AppRoutes.hotelSearch,
      // extra (nếu có) là từ khoá tìm kiếm sẵn.
      pageBuilder: (_, state) => _slide(
        state,
        HotelSearchPage(initialQuery: state.extra as String? ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.filterSort,
      // extra là bộ lọc hiện tại; màn này pop về một HotelFilter mới.
      pageBuilder: (_, state) => _slide(
        state,
        FilterSortPage(
          initial: state.extra as HotelFilter? ?? const HotelFilter(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.mapView,
      pageBuilder: (_, state) => _slide(state, const MapViewPage()),
    ),
    GoRoute(
      path: AppRoutes.guestReviews,
      pageBuilder: (_, state) =>
          _slide(state, GuestReviewsPage(hotel: state.extra as Hotel)),
    ),
    GoRoute(
      path: AppRoutes.info,
      pageBuilder: (_, state) => _slide(state, const InfoScreen()),
    ),
    GoRoute(
      path: AppRoutes.hotelDetail,
      pageBuilder: (_, state) =>
          _slide(state, HotelDetailPage(hotel: state.extra as Hotel)),
    ),
    GoRoute(
      path: AppRoutes.rooms,
      pageBuilder: (_, state) =>
          _slide(state, RoomListPage(hotel: state.extra as Hotel)),
    ),
    GoRoute(
      path: AppRoutes.roomDetail,
      pageBuilder: (_, state) {
        final (hotel, room) = state.extra as (Hotel, Room);
        return _slide(state, RoomDetailPage(hotel: hotel, room: room));
      },
    ),
    GoRoute(
      path: AppRoutes.bookingDetails,
      pageBuilder: (_, state) {
        final (hotel, room) = state.extra as (Hotel, Room);
        return _slide(state, BookingDetailsPage(hotel: hotel, room: room));
      },
    ),
    GoRoute(
      path: AppRoutes.guestDetails,
      pageBuilder: (_, state) =>
          _slide(state, GuestDetailsPage(draft: state.extra as BookingDraft)),
    ),
    GoRoute(
      path: AppRoutes.payment,
      pageBuilder: (_, state) =>
          _slide(state, PaymentPage(draft: state.extra as BookingDraft)),
    ),
    GoRoute(
      path: AppRoutes.bookingConfirmed,
      pageBuilder: (_, state) =>
          _fade(state, BookingConfirmedPage(booking: state.extra as Booking)),
    ),
    // ---- Thêm bởi BinhKhiem (myBooking/detail/cancel/review/AI) ----
    GoRoute(
      path: AppRoutes.myBookingsView,
      pageBuilder: (_, state) => _slide(state, const MyBookingsViewPage()),
    ),
    GoRoute(
      path: AppRoutes.bookingDetailView,
      pageBuilder: (_, state) =>
          _slide(state, BookingDetailViewPage(booking: state.extra as Booking)),
    ),
    GoRoute(
      path: AppRoutes.cancelBooking,
      pageBuilder: (_, state) =>
          _slide(state, CancelBookingPage(booking: state.extra as Booking)),
    ),
    GoRoute(
      path: AppRoutes.writeReview,
      pageBuilder: (_, state) =>
          _slide(state, WriteReviewPage(args: state.extra as WriteReviewArgs)),
    ),
    GoRoute(
      path: AppRoutes.assistant,
      pageBuilder: (_, state) => _slide(state, const AssistantPage()),
    ),
  ],
);

/// Trang chuyển cảnh kiểu mờ dần.
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Trang chuyển cảnh kiểu trượt từ phải sang.
CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, _, child) {
      final offset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(offset), child: child);
    },
  );
}
