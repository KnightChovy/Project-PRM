import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Xem chi tiết một booking. Cũng là use case dùng để poll trạng thái
/// thanh toán SePay và để xác nhận kết quả sau khi VNPay redirect về.
class GetBookingDetail implements UseCase<Booking, String> {
  final BookingRepository repository;
  const GetBookingDetail(this.repository);

  @override
  Future<Either<Failure, Booking>> call(String bookingId) {
    return repository.getById(bookingId);
  }
}
