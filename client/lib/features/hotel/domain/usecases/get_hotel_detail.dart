import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/hotel.dart';
import '../repositories/hotel_repository.dart';

/// Use case: lấy chi tiết một khách sạn theo id.
class GetHotelDetail implements UseCase<Hotel, String> {
  final HotelRepository repository;
  const GetHotelDetail(this.repository);

  @override
  Future<Either<Failure, Hotel>> call(String hotelId) {
    return repository.getHotelDetail(hotelId);
  }
}
