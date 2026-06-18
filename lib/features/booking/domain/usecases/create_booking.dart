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
  Future<Either<Failure, Booking>> call(CreateBookingParams p) {
    return repository.createBooking(
      hotelName: p.hotelName,
      location: p.location,
      roomName: p.roomName,
      imageUrl: p.imageUrl,
      guestName: p.guestName,
      checkIn: p.checkIn,
      checkOut: p.checkOut,
      checkInTime: p.checkInTime,
      checkOutTime: p.checkOutTime,
      adults: p.adults,
      children: p.children,
      subtotal: p.subtotal,
      taxes: p.taxes,
      discount: p.discount,
    );
  }
}

class CreateBookingParams extends Equatable {
  final String hotelName;
  final String location;
  final String roomName;
  final String imageUrl;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final String checkInTime;
  final String checkOutTime;
  final int adults;
  final int children;
  final double subtotal;
  final double taxes;
  final double discount;

  const CreateBookingParams({
    required this.hotelName,
    required this.location,
    required this.roomName,
    required this.imageUrl,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.adults,
    required this.children,
    required this.subtotal,
    required this.taxes,
    required this.discount,
  });

  @override
  List<Object?> get props => [
        hotelName,
        location,
        roomName,
        imageUrl,
        guestName,
        checkIn,
        checkOut,
        checkInTime,
        checkOutTime,
        adults,
        children,
        subtotal,
        taxes,
        discount,
      ];
}
