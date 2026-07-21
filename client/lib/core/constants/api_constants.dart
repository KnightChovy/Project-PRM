import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Địa chỉ API & các đường dẫn endpoint dùng chung.
class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    // `dotenv.env` tự ném NotInitializedError khi chưa load, che mất thông báo
    // hữu ích bên dưới — nên kiểm tra trước.
    final value = dotenv.isInitialized ? dotenv.env['BASE_URL'] : null;
    if (value == null || value.isEmpty) {
      throw StateError(
        'BASE_URL is missing. Copy .env.example to .env and set BASE_URL. '
        'In tests, call dotenv.testLoad(fileInput: "BASE_URL=...") first.',
      );
    }
    return value;
  }

  static const String sendOtp = '/auth/send-otp';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshTokens = '/auth/refresh-tokens';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String sendVerificationEmail = '/auth/send-verification-email';
  static const String verifyEmail = '/auth/verify-email';

  // ---- Booking ----
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/me';

  static String bookingById(String bookingId) => '/bookings/$bookingId';
  static String refundPreview(String bookingId) =>
      '/bookings/$bookingId/refund-preview';
  static String cancelBooking(String bookingId) =>
      '/bookings/$bookingId/cancel';

  // ---- Payment ----
  static String vnpayCheckout(String bookingId) =>
      '/payments/bookings/$bookingId/vnpay';
  static String sepayCheckout(String bookingId) =>
      '/payments/bookings/$bookingId/sepay';
  static String walletPayment(String bookingId) =>
      '/payments/bookings/$bookingId/wallet';

  // ---- Hotel ----
  static const String hotels = '/hotels'; // GET tìm/danh sách khách sạn
  static const String hotelDestinations =
      '/hotels/destinations'; // GET điểm đến phổ biến
  static String hotelById(String hotelId) => '/hotels/$hotelId'; // GET chi tiết

  // ---- Room types (loại phòng của 1 khách sạn) ----
  static String hotelRoomTypes(String hotelId) =>
      '/hotels/$hotelId/room-types'; // GET danh sách loại phòng
  static String hotelRoomTypeById(String hotelId, String roomTypeId) =>
      '/hotels/$hotelId/room-types/$roomTypeId'; // GET chi tiết loại phòng

  // ---- Review ----
  static const String reviews = '/reviews'; // POST tạo đánh giá
  static const String myReviews = '/reviews/me'; // GET đánh giá của tôi

  // ---- Upload ----
  static const String uploads = '/uploads'; // POST 1 file (field "file") → { url }

  // ---- Hồ sơ người dùng ----
  /// GET: lấy hồ sơ (kèm `profile`) — PATCH: cập nhật hồ sơ.
  static const String me = '/users/me';
  static const String changePassword = '/users/me/password';

  // ---- Trợ lý AI (chatbot) ----
  static const String conversationMessages = '/conversations/messages';
  static const String myConversation = '/conversations/me';
}
