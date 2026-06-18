import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

/// Use case: tạo một lượt đặt phòng.
class CreateBooking implements UseCase<Booking, CreateBookingParams> {
  final BookingRepository repository;
  const CreateBooking(this.repository);

  @override
  Future<Either<Failure, Booking>> call(CreateBookingParams params) {
    return repository.createBooking(
      roomName: params.roomName,
      imageUrl: params.imageUrl,
      pricePerNight: params.pricePerNight,
      nights: params.nights,
      guests: params.guests,
      taxesAndFees: params.taxesAndFees,
    );
  }
}

class CreateBookingParams extends Equatable {
  final String roomName;
  final String imageUrl;
  final double pricePerNight;
  final int nights;
  final int guests;
  final double taxesAndFees;

  const CreateBookingParams({
    required this.roomName,
    required this.imageUrl,
    required this.pricePerNight,
    required this.nights,
    required this.guests,
    required this.taxesAndFees,
  });

  @override
  List<Object?> get props =>
      [roomName, imageUrl, pricePerNight, nights, guests, taxesAndFees];
}
