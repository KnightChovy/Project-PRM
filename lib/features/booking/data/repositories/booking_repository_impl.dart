import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_data_source.dart';

/// Hiện thực [BookingRepository] dùng kho in-memory.
class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource local;
  const BookingRepositoryImpl(this.local);

  @override
  Future<Either<Failure, Booking>> createBooking({
    required String hotelName,
    required String location,
    required String roomName,
    required String imageUrl,
    required String guestName,
    required DateTime checkIn,
    required DateTime checkOut,
    required String checkInTime,
    required String checkOutTime,
    required int adults,
    required int children,
    required double subtotal,
    required double taxes,
    required double discount,
  }) async {
    final now = DateTime.now();
    final ms = now.millisecondsSinceEpoch;
    final booking = Booking(
      id: ms.toString(),
      code: 'SS-${(ms % 1000000).toString().padLeft(6, '0')}',
      hotelName: hotelName,
      location: location,
      roomName: roomName,
      imageUrl: imageUrl,
      guestName: guestName,
      checkIn: checkIn,
      checkOut: checkOut,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      adults: adults,
      children: children,
      subtotal: subtotal,
      taxes: taxes,
      discount: discount,
      createdAt: now,
    );
    local.add(booking);
    return Right(booking);
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings() async {
    return Right(local.getAll());
  }
}
