import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/api_error.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../models/room_model.dart';

/// Gọi API loại phòng của một khách sạn (public):
///  - `GET /hotels/:id/room-types`             → danh sách loại phòng
///  - `GET /hotels/:id/room-types/:roomTypeId` → chi tiết một loại phòng
///
/// Lỗi thì NÉM Exception (RepositoryImpl bắt và đổi thành Failure).
abstract interface class RoomRemoteDataSource {
  Future<List<RoomModel>> getRoomTypes(String hotelId);
  Future<RoomModel> getRoomTypeDetail(String hotelId, String roomTypeId);
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final DioClient client;
  const RoomRemoteDataSourceImpl(this.client);

  @override
  Future<List<RoomModel>> getRoomTypes(String hotelId) async {
    try {
      final res = await client.dio.get(ApiConstants.hotelRoomTypes(hotelId));
      // API trả về MẢNG loại phòng (không bọc envelope).
      final list = res.data is List ? res.data as List : const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(RoomModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được danh sách phòng');
    }
  }

  @override
  Future<RoomModel> getRoomTypeDetail(String hotelId, String roomTypeId) async {
    try {
      final res =
          await client.dio.get(ApiConstants.hotelRoomTypeById(hotelId, roomTypeId));
      return RoomModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được chi tiết phòng');
    }
  }
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  throw const ServerException(message: 'Dữ liệu trả về không hợp lệ');
}
