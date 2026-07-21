import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/hotel_review.dart';
import '../repositories/review_repository.dart';

/// Use case: lấy đánh giá công khai của một khách sạn (theo hotelId).
class GetHotelReviews implements UseCase<List<HotelReview>, String> {
  final ReviewRepository repository;
  const GetHotelReviews(this.repository);

  @override
  Future<Either<Failure, List<HotelReview>>> call(String hotelId) {
    return repository.getHotelReviews(hotelId);
  }
}
