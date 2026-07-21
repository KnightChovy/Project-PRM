import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/checkout.dart';
import '../repositories/booking_repository.dart';

/// Lấy link cổng VNPay cho một booking đang chờ thanh toán.
class StartVnpayCheckout implements UseCase<VnpayCheckout, String> {
  final BookingRepository repository;
  const StartVnpayCheckout(this.repository);

  @override
  Future<Either<Failure, VnpayCheckout>> call(String bookingId) {
    return repository.startVnpayCheckout(bookingId);
  }
}
