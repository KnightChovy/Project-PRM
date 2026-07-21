import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

/// Use case: lấy danh sách loại phòng của một khách sạn (theo hotelId).
class GetRoomTypes implements UseCase<List<Room>, String> {
  final RoomRepository repository;
  const GetRoomTypes(this.repository);

  @override
  Future<Either<Failure, List<Room>>> call(String hotelId) {
    return repository.getRoomTypes(hotelId);
  }
}
