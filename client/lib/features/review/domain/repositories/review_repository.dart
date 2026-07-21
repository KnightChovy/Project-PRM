import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/review.dart';
import '../entities/hotel_review.dart';

/// Hợp đồng cho việc đánh giá. Domain khai báo, Data hiện thực.
abstract interface class ReviewRepository {
  /// Gửi một đánh giá mới cho booking đã trả phòng.
  /// Server tự lấy hotelId từ booking → client chỉ gửi bookingId + điểm.
  Future<Either<Failure, Review>> submitReview({
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

  /// Lấy toàn bộ đánh giá đã gửi (để kiểm tra đã đánh giá chỗ nào, xem lại).
  Future<Either<Failure, List<Review>>> getMyReviews();

  /// Tải một ảnh (bytes) lên `/uploads`, trả về URL để đính vào đánh giá.
  Future<Either<Failure, String>> uploadImage({
    required List<int> bytes,
    required String filename,
  });

  /// Đánh giá công khai của một khách sạn (màn Guest Reviews).
  Future<Either<Failure, List<HotelReview>>> getHotelReviews(String hotelId);
}
