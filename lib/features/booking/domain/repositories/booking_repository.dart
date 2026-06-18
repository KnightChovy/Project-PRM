import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/booking.dart';

/// Hợp đồng cho việc đặt phòng. Domain khai báo, Data hiện thực.
abstract interface class BookingRepository {
  /// Tạo một lượt đặt phòng mới (repo tự sinh id + mã code).
  Future<Either<Failure, Booking>> createBooking({
    required String hotelName,
    required String location,
    required String roomName,
    required String imageUrl,
    required String guestName,
    required DateTime checkIn,
    required DateTime checkOut,
    required String checkInTime,
    required String checkOutTime,
    required int adults,
    required int children,
    required double subtotal,
    required double taxes,
    required double discount,
  });

  /// Lấy danh sách đặt phòng của người dùng.
  Future<Either<Failure, List<Booking>>> getMyBookings();
}
