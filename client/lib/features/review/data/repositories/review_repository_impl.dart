import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_local_data_source.dart';
import '../models/review_model.dart';

/// Hiện thực [ReviewRepository]. NƠI DUY NHẤT đổi Exception → Failure.
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewLocalDataSource local;
  const ReviewRepositoryImpl(this.local);

  @override
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
  }) async {
    try {
      final now = DateTime.now();
      final model = ReviewModel(
        id: 'rv_${now.microsecondsSinceEpoch}',
        hotelName: hotelName,
        location: location,
        overall: overall,
        cleanliness: cleanliness,
        locationRating: locationRating,
        service: service,
        value: value,
        comment: comment,
        isAnonymous: isAnonymous,
        createdAt: now,
      );
      final saved = await local.save(model);
      return Right(saved);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getMyReviews() async {
    try {
      return Right(local.getAll());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
