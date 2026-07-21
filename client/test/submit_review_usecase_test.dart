import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/review/domain/entities/review.dart';
import 'package:smart_stay_ai/features/review/domain/entities/hotel_review.dart';
import 'package:smart_stay_ai/features/review/domain/repositories/review_repository.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';

/// Fake repository tự viết cho review (không dùng mocktail).
class _FakeReviewRepository implements ReviewRepository {
  bool called = false;

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
    List<String> images = const [],
  }) async {
    called = true;
    return Right(Review(
      id: 'rv_1',
      bookingId: bookingId,
      hotelName: 'Amanoi Resort',
      location: '',
      overall: overall,
      cleanliness: cleanliness,
      locationRating: locationRating,
      service: service,
      value: value,
      comment: comment,
      isAnonymous: false,
      createdAt: DateTime(2026, 1, 1),
    ));
  }

  @override
  Future<Either<Failure, List<Review>>> getMyReviews() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<HotelReview>>> getHotelReviews(
    String hotelId,
  ) async =>
      const Right([]);

  @override
  Future<Either<Failure, String>> uploadImage({
    required List<int> bytes,
    required String filename,
  }) async =>
      const Right('https://cdn.test/img.jpg');
}

SubmitReviewParams _params({required int overall}) => SubmitReviewParams(
      bookingId: 'bk-uuid-1',
      overall: overall,
      cleanliness: 4,
      locationRating: 5,
      service: 4,
      value: 4,
      comment: 'Tuyệt vời',
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
