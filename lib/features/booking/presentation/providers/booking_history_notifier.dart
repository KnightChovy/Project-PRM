import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_history_item.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/cancel_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_booking_history.dart';

enum HistoryStatus { initial, loading, success, error }

/// Quản lý trạng thái màn "My Bookings" (3 tab). Đăng ký SINGLETON ở DI để
/// sau khi huỷ ở màn chi tiết, danh sách tự cập nhật.
class BookingHistoryNotifier extends ChangeNotifier {
  final GetBookingHistory getBookingHistory;
  final CancelBooking cancelBooking;
  // Tái dùng usecase tạo booking của Phat để "đặt lại" (Rebook).
  final CreateBooking createBooking;

  BookingHistoryNotifier({
    required this.getBookingHistory,
    required this.cancelBooking,
    required this.createBooking,
  });

  HistoryStatus status = HistoryStatus.initial;
  List<BookingHistoryItem> items = const [];
  String? errorMessage;

  bool get isLoading => status == HistoryStatus.loading;

  List<BookingHistoryItem> get upcoming =>
      items.where((e) => e.isUpcoming).toList();
  List<BookingHistoryItem> get completed =>
      items.where((e) => e.isCompleted).toList();
  List<BookingHistoryItem> get cancelled =>
      items.where((e) => e.isCancelled).toList();

  /// Tải lịch sử đặt phòng.
  Future<void> load() async {
    status = HistoryStatus.loading;
    notifyListeners();

    final result = await getBookingHistory(const NoParams());
    result.fold(
      (failure) {
        status = HistoryStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = HistoryStatus.success;
        items = data;
      },
    );
    notifyListeners();
  }

  /// Huỷ một booking rồi tải lại danh sách. Trả về true nếu thành công.
  Future<bool> cancel(String bookingId) async {
    final result = await cancelBooking(CancelBookingParams(bookingId));
    return result.fold(
      (failure) async {
        errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) async {
        await load();
        return true;
      },
    );
  }

  /// Đặt lại một booking đã huỷ: tạo booking MỚI cùng khách sạn/phòng/giá
  /// nhưng với ngày ở tương lai (giữ nguyên số đêm). Bản đã huỷ vẫn giữ trong
  /// lịch sử. Trả về true nếu thành công.
  Future<bool> rebook(Booking old) async {
    final now = DateTime.now();
    final checkIn = now.add(const Duration(days: 30));
    final nights = old.nights <= 0 ? 1 : old.nights;
    final checkOut = checkIn.add(Duration(days: nights));

    final result = await createBooking(CreateBookingParams(
      hotelName: old.hotelName,
      location: old.location,
      roomName: old.roomName,
      imageUrl: old.imageUrl,
      guestName: old.guestName,
      checkIn: checkIn,
      checkOut: checkOut,
      checkInTime: old.checkInTime,
      checkOutTime: old.checkOutTime,
      adults: old.adults,
      children: old.children,
      subtotal: old.subtotal,
      taxes: old.taxes,
      discount: old.discount,
    ));
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) async {
        await load();
        return true;
      },
    );
  }
}
