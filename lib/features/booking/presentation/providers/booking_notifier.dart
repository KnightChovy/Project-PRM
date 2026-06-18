import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_my_bookings.dart';

enum BookingStatus { initial, loading, success, error }

/// Quản lý trạng thái đặt phòng. Đăng ký SINGLETON ở DI để màn xác nhận
/// và tab "My Booking" cùng dùng chung một danh sách.
class BookingNotifier extends ChangeNotifier {
  final CreateBooking createBooking;
  final GetMyBookings getMyBookings;

  BookingNotifier({
    required this.createBooking,
    required this.getMyBookings,
  });

  BookingStatus status = BookingStatus.initial;
  List<Booking> bookings = const [];
  String? errorMessage;

  bool get isLoading => status == BookingStatus.loading;

  /// Tải danh sách đặt phòng của tôi.
  Future<void> loadBookings() async {
    status = BookingStatus.loading;
    notifyListeners();

    final result = await getMyBookings(const NoParams());
    result.fold(
      (failure) {
        status = BookingStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = BookingStatus.success;
        bookings = data;
      },
    );
    notifyListeners();
  }

  /// Tạo booking mới. Trả về [Booking] vừa tạo, hoặc null nếu lỗi.
  Future<Booking?> book(CreateBookingParams params) async {
    final result = await createBooking(params);
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
        return null;
      },
      (booking) {
        // Cập nhật lại danh sách để tab My Booking thấy ngay.
        bookings = [booking, ...bookings];
        status = BookingStatus.success;
        notifyListeners();
        return booking;
      },
    );
  }
}
