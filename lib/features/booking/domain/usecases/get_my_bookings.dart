import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Use case: lấy danh sách đặt phòng của tôi.
class GetMyBookings implements UseCase<List<Booking>, NoParams> {
  final BookingRepository repository;
  const GetMyBookings(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(NoParams params) {
    return repository.getMyBookings();
  }
}
