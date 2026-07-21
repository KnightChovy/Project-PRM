import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/api_error.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../models/review_model.dart';
import '../models/hotel_review_model.dart';

/// Gọi API đánh giá: `POST /reviews` + `GET /reviews/me` + `GET /reviews?hotelId=`.
/// Lỗi thì NÉM Exception (RepositoryImpl bắt và đổi thành Failure).
abstract interface class ReviewRemoteDataSource {
  Future<ReviewModel> submit({
    required String bookingId,
    required int overall,
    required int cleanliness,
    required int locationRating,
    required int service,
    required int value,
    required String comment,
    String? title,
    List<String> images,
  });

  Future<List<ReviewModel>> getMyReviews();

  /// Đánh giá công khai của một khách sạn.
  Future<List<HotelReviewModel>> getHotelReviews(String hotelId);

  /// Tải 1 ảnh (bytes) lên `/uploads`, trả về URL Cloudinary.
  Future<String> uploadImage({
    required List<int> bytes,
    required String filename,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient client;
  const ReviewRemoteDataSourceImpl(this.client);

  @override
  Future<ReviewModel> submit({
    required String bookingId,
    required int overall,
    required int cleanliness,
    required int locationRating,
    required int service,
    required int value,
    required String comment,
    String? title,
    List<String> images = const [],
  }) async {
    try {
      // Server tự lấy hotelId từ booking → chỉ gửi bookingId + điểm + nội dung.
      final res = await client.dio.post(
        ApiConstants.reviews,
        data: {
          'bookingId': bookingId,
          'overallRating': overall,
          'cleanlinessRating': cleanliness,
          'serviceRating': service,
          'locationRating': locationRating,
          'valueRating': value,
          'content': comment,
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
          if (images.isNotEmpty) 'images': images,
        },
      );
      return ReviewModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Gửi đánh giá thất bại');
    }
  }

  @override
  Future<String> uploadImage({
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final form = FormData.fromMap({
        // Field PHẢI tên "file" (multer.single('file')); folder gom ảnh review.
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res = await client.dio.post(
        ApiConstants.uploads,
        queryParameters: {'folder': 'reviews'},
        data: form,
      );
      final url = _asMap(res.data)['url'];
      if (url is! String || url.isEmpty) {
        throw const ServerException(message: 'Tải ảnh lên thất bại');
      }
      return url;
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Tải ảnh lên thất bại');
    }
  }

  @override
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final res = await client.dio.get(ApiConstants.myReviews);
      // API trả envelope phân trang { results, page, ... }.
      final data = res.data;
      final list = data is Map ? (data['results'] as List? ?? const []) : const [];
      return list
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được đánh giá của bạn');
    }
  }

  @override
  Future<List<HotelReviewModel>> getHotelReviews(String hotelId) async {
    try {
      final res = await client.dio.get(
        ApiConstants.reviews,
        // Lấy nhiều nhất trong 1 trang (max 100) — đủ cho màn Guest Reviews.
        queryParameters: {'hotelId': hotelId, 'limit': 100},
      );
      final data = res.data;
      final list = data is Map ? (data['results'] as List? ?? const []) : const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(HotelReviewModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được đánh giá khách sạn');
    }
  }
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  throw const ServerException(message: 'Dữ liệu trả về không hợp lệ');
}
