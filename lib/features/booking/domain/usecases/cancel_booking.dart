import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/checkout.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Huỷ booking và chọn nơi nhận tiền hoàn.
class CancelBooking
    implements UseCase<Booking, CancelBookingParams> {
  final BookingRepository repository;
  const CancelBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CancelBookingParams params) {
    return repository.cancel(
      bookingId: params.bookingId,
      destination: params.destination,
      reason: params.reason,
    );
  }
}

/// Không dùng Equatable vì [RefundDestination] là sealed class thường —
/// so sánh theo tham chiếu là đủ cho params.
class CancelBookingParams {
  final String bookingId;
  final RefundDestination destination;
  final String? reason;

  const CancelBookingParams({
    required this.bookingId,
    required this.destination,
    this.reason,
  });
}
