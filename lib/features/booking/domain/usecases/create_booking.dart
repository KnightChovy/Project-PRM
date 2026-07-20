import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/booking.dart';
import '../entities/booking_status.dart';
import '../repositories/booking_repository.dart';

/// Đặt một phòng. Server tính tiền và quyết định trạng thái/hold.
class CreateBooking
    implements UseCase<Booking, CreateBookingParams> {
  final BookingRepository repository;
  const CreateBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CreateBookingParams params) {
    return repository.create(
      hotelId: params.hotelId,
      roomTypeId: params.roomTypeId,
      checkInDate: params.checkInDate,
      checkOutDate: params.checkOutDate,
      numGuests: params.numGuests,
      specialRequests: params.specialRequests,
      paymentMethod: params.paymentMethod,
    );
  }
}

class CreateBookingParams extends Equatable {
  final String hotelId;
  final String roomTypeId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numGuests;
  final String? specialRequests;
  final PaymentMethod paymentMethod;

  const CreateBookingParams({
    required this.hotelId,
    required this.roomTypeId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numGuests,
    this.specialRequests,
    this.paymentMethod = PaymentMethod.vnpay,
  });

  @override
  List<Object?> get props => [
        hotelId,
        roomTypeId,
        checkInDate,
        checkOutDate,
        numGuests,
        specialRequests,
        paymentMethod,
      ];
}
