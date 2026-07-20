import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/review/domain/entities/review.dart';
import 'package:smart_stay_ai/features/review/domain/repositories/review_repository.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';

/// Fake repository tự viết cho review.
class _FakeReviewRepository implements ReviewRepository {
  bool called = false;

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
    called = true;
    return Right(Review(
      id: 'rv_1',
      hotelName: hotelName,
      location: location,
      overall: overall,
      cleanliness: cleanliness,
      locationRating: locationRating,
      service: service,
      value: value,
      comment: comment,
      isAnonymous: isAnonymous,
      createdAt: DateTime(2026, 1, 1),
    ));
  }

  @override
  Future<Either<Failure, List<Review>>> getMyReviews() async =>
      const Right([]);
}

SubmitReviewParams _params({required int overall}) => SubmitReviewParams(
      hotelName: 'Amanoi Resort',
      location: 'Ninh Thuan',
      overall: overall,
      cleanliness: 4,
      locationRating: 5,
      service: 4,
      value: 4,
      comment: 'Tuyệt vời',
      isAnonymous: false,
    );

void main() {
  group('SubmitReview use case', () {
    test('chặn gửi khi chưa chấm sao tổng quan (overall = 0)', () async {
      final repo = _FakeReviewRepository();
      final usecase = SubmitReview(repo);

      final result = await usecase(_params(overall: 0));

      expect(result.isLeft(), isTrue);
      expect(repo.called, isFalse); // không được chạm tới repository
    });

    test('cho phép gửi khi overall hợp lệ', () async {
      final repo = _FakeReviewRepository();
      final usecase = SubmitReview(repo);

      final result = await usecase(_params(overall: 5));

      expect(result.isRight(), isTrue);
      expect(repo.called, isTrue);
    });
  });
}
