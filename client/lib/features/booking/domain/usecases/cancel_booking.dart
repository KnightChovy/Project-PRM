import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Huỷ booking. Tiền hoàn do server tự tính, khách không chọn nơi nhận.
class CancelBooking implements UseCase<Booking, CancelBookingParams> {
  final BookingRepository repository;
  const CancelBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CancelBookingParams params) {
    return repository.cancel(
      bookingId: params.bookingId,
      reason: params.reason,
    );
  }
}

class CancelBookingParams extends Equatable {
  final String bookingId;
  final String? reason;

  const CancelBookingParams({required this.bookingId, this.reason});

  @override
  List<Object?> get props => [bookingId, reason];
}
