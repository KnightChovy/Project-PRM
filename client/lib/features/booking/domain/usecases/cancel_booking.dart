import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../repositories/booking_history_repository.dart';

/// Use case: huỷ một lượt đặt phòng.
class CancelBooking implements UseCase<Unit, CancelBookingParams> {
  final BookingHistoryRepository repository;
  const CancelBooking(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CancelBookingParams params) {
    if (params.bookingId.trim().isEmpty) {
      return Future.value(
        const Left(ServerFailure(message: 'Thiếu mã booking cần huỷ.')),
      );
    }
    return repository.cancelBooking(params.bookingId);
  }
}

class CancelBookingParams extends Equatable {
  final String bookingId;
  const CancelBookingParams(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
