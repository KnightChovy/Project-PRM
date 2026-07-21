import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exception_to_failure.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/checkout.dart';
import '../../domain/entities/paginated.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

/// Hiện thực [BookingRepository].
/// Đây là NƠI DUY NHẤT đổi Exception -> Failure (qua [guardApiCall]).
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remote;
  const BookingRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Booking>> create({
    required String hotelId,
    required String roomTypeId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numGuests,
    String? specialRequests,
    PaymentMethod paymentMethod = PaymentMethod.vnpay,
  }) {
    return guardApiCall(
      () => remote.create(
        hotelId: hotelId,
        roomTypeId: roomTypeId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        numGuests: numGuests,
        specialRequests: specialRequests,
        paymentMethod: paymentMethod,
      ),
    );
  }

  @override
  Future<Either<Failure, Paginated<Booking>>> getMine({
    BookingStatus? status,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    final result = await guardApiCall(
      () => remote.getMine(
        status: status,
        page: page,
        limit: limit,
        sortBy: sortBy,
      ),
    );
    // Paginated<BookingModel> -> Paginated<Booking>: Presentation chỉ
    // được thấy Entity, không thấy Model.
    return result.map(
      (paged) => Paginated<Booking>(
        items: List<Booking>.unmodifiable(paged.items),
        page: paged.page,
        limit: paged.limit,
        totalPages: paged.totalPages,
        totalResults: paged.totalResults,
      ),
    );
  }

  @override
  Future<Either<Failure, Booking>> getById(String bookingId) {
    return guardApiCall(() => remote.getById(bookingId));
  }

  @override
  Future<Either<Failure, Booking>> cancel({
    required String bookingId,
    String? reason,
  }) {
    return guardApiCall(
      () => remote.cancel(bookingId: bookingId, reason: reason),
    );
  }

  @override
  Future<Either<Failure, VnpayCheckout>> startVnpayCheckout(String bookingId) {
    return guardApiCall(() => remote.startVnpayCheckout(bookingId));
  }

  @override
  Future<Either<Failure, SepayCheckout>> startSepayCheckout(String bookingId) {
    return guardApiCall(() => remote.startSepayCheckout(bookingId));
  }

  @override
  Future<Either<Failure, WalletPaymentResult>> payWithWallet(String bookingId) {
    return guardApiCall(() => remote.payWithWallet(bookingId));
  }
}
