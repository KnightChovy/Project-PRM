import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/booking.dart';

/// Hợp đồng cho việc đặt phòng. Domain khai báo, Data hiện thực.
abstract interface class BookingRepository {
  /// Tạo một lượt đặt phòng mới.
  Future<Either<Failure, Booking>> createBooking({
    required String roomName,
    required String imageUrl,
    required double pricePerNight,
    required int nights,
    required int guests,
    required double taxesAndFees,
  });

  /// Lấy danh sách đặt phòng của người dùng.
  Future<Either<Failure, List<Booking>>> getMyBookings();
}
