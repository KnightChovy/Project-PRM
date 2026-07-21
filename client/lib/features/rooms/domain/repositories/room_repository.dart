import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/room.dart';

/// Hợp đồng cho loại phòng. Domain khai báo, Data hiện thực.
abstract interface class RoomRepository {
  /// Danh sách loại phòng đang bán của một khách sạn (public).
  Future<Either<Failure, List<Room>>> getRoomTypes(String hotelId);

  /// Chi tiết một loại phòng theo id (public).
  Future<Either<Failure, Room>> getRoomTypeDetail(
    String hotelId,
    String roomTypeId,
  );
}
