import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exception_to_failure.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_remote_data_source.dart';

/// Hiện thực [RoomRepository] gọi API thật.
/// `guardApiCall` là chỗ DUY NHẤT đổi Exception → Failure.
class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remote;
  const RoomRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Room>>> getRoomTypes(String hotelId) {
    return guardApiCall(() => remote.getRoomTypes(hotelId));
  }

  @override
  Future<Either<Failure, Room>> getRoomTypeDetail(
    String hotelId,
    String roomTypeId,
  ) {
    return guardApiCall(() => remote.getRoomTypeDetail(hotelId, roomTypeId));
  }
}
