import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/hotel.dart';

/// Hợp đồng cho khách sạn. Domain khai báo, Data hiện thực.
abstract interface class HotelRepository {
  /// Tìm/danh sách khách sạn (public). Bỏ trống city = tất cả.
  Future<Either<Failure, List<Hotel>>> searchHotels({
    String? city,
    int? page,
    int? limit,
    String? sortBy,
  });

  /// Chi tiết một khách sạn theo id (public).
  Future<Either<Failure, Hotel>> getHotelDetail(String hotelId);
}
