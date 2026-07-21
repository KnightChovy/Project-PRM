import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/api_error.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../models/hotel_model.dart';
import '../models/destination_model.dart';

/// Gọi API khách sạn: `GET /hotels` (search) + `GET /hotels/:id` (detail)
/// + `GET /hotels/destinations` (điểm đến phổ biến).
/// Lỗi thì NÉM Exception (RepositoryImpl bắt và đổi thành Failure).
abstract interface class HotelRemoteDataSource {
  Future<List<HotelModel>> searchHotels({
    String? city,
    int? page,
    int? limit,
    String? sortBy,
  });

  Future<HotelModel> getHotelDetail(String hotelId);

  Future<List<DestinationModel>> getDestinations();
}

class HotelRemoteDataSourceImpl implements HotelRemoteDataSource {
  final DioClient client;
  const HotelRemoteDataSourceImpl(this.client);

  @override
  Future<List<HotelModel>> searchHotels({
    String? city,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final res = await client.dio.get(
        ApiConstants.hotels,
        queryParameters: {
          if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
          'page': ?page,
          'limit': ?limit,
          'sortBy': ?sortBy,
        },
      );
      // API trả envelope phân trang { results, page, ... }.
      final data = res.data;
      final list = data is Map ? (data['results'] as List? ?? const []) : const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(HotelModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được danh sách khách sạn');
    }
  }

  @override
  Future<HotelModel> getHotelDetail(String hotelId) async {
    try {
      final res = await client.dio.get(ApiConstants.hotelById(hotelId));
      return HotelModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được chi tiết khách sạn');
    }
  }

  @override
  Future<List<DestinationModel>> getDestinations() async {
    try {
      final res = await client.dio.get(ApiConstants.hotelDestinations);
      final list = res.data is List ? res.data as List : const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(DestinationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được điểm đến');
    }
  }
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  throw const ServerException(message: 'Dữ liệu trả về không hợp lệ');
}
