import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/room.dart';
import '../repositories/room_repository.dart';

/// Use case: lấy chi tiết một loại phòng theo (hotelId, roomTypeId).
class GetRoomTypeDetail implements UseCase<Room, RoomTypeDetailParams> {
  final RoomRepository repository;
  const GetRoomTypeDetail(this.repository);

  @override
  Future<Either<Failure, Room>> call(RoomTypeDetailParams params) {
    return repository.getRoomTypeDetail(params.hotelId, params.roomTypeId);
  }
}

class RoomTypeDetailParams extends Equatable {
  final String hotelId;
  final String roomTypeId;

  const RoomTypeDetailParams({required this.hotelId, required this.roomTypeId});

  @override
  List<Object?> get props => [hotelId, roomTypeId];
}
