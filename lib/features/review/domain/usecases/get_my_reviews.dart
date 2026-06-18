import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Use case: lấy danh sách đánh giá đã gửi của tôi.
class GetMyReviews implements UseCase<List<Review>, NoParams> {
  final ReviewRepository repository;
  const GetMyReviews(this.repository);

  @override
  Future<Either<Failure, List<Review>>> call(NoParams params) {
    return repository.getMyReviews();
  }
}
