import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/checkout.dart';
import '../repositories/booking_repository.dart';

/// Lấy mã QR chuyển khoản SePay cho một booking đang chờ thanh toán.
class StartSepayCheckout implements UseCase<SepayCheckout, String> {
  final BookingRepository repository;
  const StartSepayCheckout(this.repository);

  @override
  Future<Either<Failure, SepayCheckout>> call(String bookingId) {
    return repository.startSepayCheckout(bookingId);
  }
}
