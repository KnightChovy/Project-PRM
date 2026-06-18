import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/review.dart';

/// Hợp đồng cho việc đánh giá. Domain khai báo, Data hiện thực.
abstract interface class ReviewRepository {
  /// Gửi một đánh giá mới (repo tự sinh id + thời điểm tạo).
  Future<Either<Failure, Review>> submitReview({
    required String hotelName,
    required String location,
    required int overall,
    required int cleanliness,
    required int locationRating,
    required int service,
    required int value,
    required String comment,
    required bool isAnonymous,
  });

  /// Lấy toàn bộ đánh giá đã gửi (để kiểm tra đã đánh giá chỗ nào, xem lại).
  Future<Either<Failure, List<Review>>> getMyReviews();
}
