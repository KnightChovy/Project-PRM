import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/booking_history_item.dart';
import '../repositories/booking_history_repository.dart';

/// Use case: lấy lịch sử đặt phòng (cho màn "My Bookings" có 3 tab).
class GetBookingHistory
    implements UseCase<List<BookingHistoryItem>, NoParams> {
  final BookingHistoryRepository repository;
  const GetBookingHistory(this.repository);

  @override
  Future<Either<Failure, List<BookingHistoryItem>>> call(NoParams params) {
    return repository.getHistory();
  }
}
