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
    required String roomName,
    required String imageUrl,
    required double pricePerNight,
    required int nights,
    required int guests,
    required double taxesAndFees,
  }) async {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomName: roomName,
      imageUrl: imageUrl,
      pricePerNight: pricePerNight,
      nights: nights,
      guests: guests,
      taxesAndFees: taxesAndFees,
      createdAt: DateTime.now(),
    );
    local.add(booking);
    return Right(booking);
  }

  @override
  Future<Either<Failure, List<Booking>>> getMyBookings() async {
    return Right(local.getAll());
  }
}
