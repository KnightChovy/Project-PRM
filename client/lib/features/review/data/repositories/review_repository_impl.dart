import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exception_to_failure.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/hotel_review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';

/// Hiện thực [ReviewRepository] gọi API thật.
/// `guardApiCall` là chỗ DUY NHẤT đổi Exception → Failure.
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remote;
  const ReviewRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, Review>> submitReview({
    required String bookingId,
    required int overall,
    required int cleanliness,
    required int locationRating,
    required int service,
    required int value,
    required String comment,
    String? title,
  }) {
    return guardApiCall(() => remote.submit(
          bookingId: bookingId,
          overall: overall,
          cleanliness: cleanliness,
          locationRating: locationRating,
          service: service,
          value: value,
          comment: comment,
          title: title,
        ));
  }

  @override
  Future<Either<Failure, List<Review>>> getMyReviews() {
    return guardApiCall(() => remote.getMyReviews());
  }

  @override
  Future<Either<Failure, List<HotelReview>>> getHotelReviews(String hotelId) {
    return guardApiCall(() => remote.getHotelReviews(hotelId));
  }
}
