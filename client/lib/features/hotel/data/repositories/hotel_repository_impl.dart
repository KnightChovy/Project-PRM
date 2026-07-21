import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exception_to_failure.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../datasources/hotel_remote_data_source.dart';

/// Hiện thực [HotelRepository] gọi API thật.
/// `guardApiCall` là chỗ DUY NHẤT đổi Exception → Failure.
class HotelRepositoryImpl implements HotelRepository {
  final HotelRemoteDataSource remote;
  const HotelRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Hotel>>> searchHotels({
    String? city,
    int? page,
    int? limit,
    String? sortBy,
  }) {
    return guardApiCall(() => remote.searchHotels(
          city: city,
          page: page,
          limit: limit,
          sortBy: sortBy,
        ));
  }

  @override
  Future<Either<Failure, Hotel>> getHotelDetail(String hotelId) {
    return guardApiCall(() => remote.getHotelDetail(hotelId));
  }
}
