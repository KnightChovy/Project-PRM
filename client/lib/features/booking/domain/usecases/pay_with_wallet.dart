import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/checkout.dart';
import '../repositories/booking_repository.dart';

/// Trừ ví cho booking. Ví thiếu thì booking vẫn `pending` và phần còn lại
/// được trả tiếp bằng VNPay/SePay.
class PayWithWallet implements UseCase<WalletPaymentResult, String> {
  final BookingRepository repository;
  const PayWithWallet(this.repository);

  @override
  Future<Either<Failure, WalletPaymentResult>> call(String bookingId) {
    return repository.payWithWallet(bookingId);
  }
}
