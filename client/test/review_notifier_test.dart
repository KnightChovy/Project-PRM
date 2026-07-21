import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/review/domain/entities/hotel_review.dart';
import 'package:smart_stay_ai/features/review/domain/entities/review.dart';
import 'package:smart_stay_ai/features/review/domain/repositories/review_repository.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/get_my_reviews.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/upload_review_image.dart';
import 'package:smart_stay_ai/features/review/presentation/providers/review_notifier.dart';

/// Fake repository ghi lại các URL ảnh mà đánh giá gửi kèm + đếm số lần upload.
class _FakeRepo implements ReviewRepository {
  int uploadCount = 0;
  List<String>? submittedImages;
  Failure? uploadFailure;

  @override
  Future<Either<Failure, String>> uploadImage({
    required List<int> bytes,
    required String filename,
  }) async {
    uploadCount++;
    if (uploadFailure != null) return Left(uploadFailure!);
    return Right('https://cdn.test/$filename');
  }

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
    submittedImages = images;
    return Right(Review(
      id: 'rv_1',
      bookingId: bookingId,
      hotelName: 'Amanoi',
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
  Future<Either<Failure, List<Review>>> getMyReviews() async => const Right([]);

  @override
  Future<Either<Failure, List<HotelReview>>> getHotelReviews(String hotelId) async =>
      const Right([]);
}

ReviewNotifier _notifier(_FakeRepo repo) => ReviewNotifier(
      SubmitReview(repo),
      GetMyReviews(repo),
      UploadReviewImage(repo),
    );

SubmitReviewParams _params() => const SubmitReviewParams(
      bookingId: 'bk-1',
      overall: 5,
      cleanliness: 5,
      locationRating: 4,
      service: 5,
      value: 4,
      comment: 'Tuyệt vời',
    );

void main() {
  test('submit tải ảnh lên trước rồi đính URL vào đánh giá', () async {
    final repo = _FakeRepo();
    final notifier = _notifier(repo);

    final ok = await notifier.submit(
      _params(),
      photos: const [
        UploadReviewImageParams(bytes: [1, 2, 3], filename: 'a.jpg'),
        UploadReviewImageParams(bytes: [4, 5, 6], filename: 'b.jpg'),
      ],
    );

    expect(ok, isTrue);
    expect(repo.uploadCount, 2);
    expect(repo.submittedImages, ['https://cdn.test/a.jpg', 'https://cdn.test/b.jpg']);
  });

  test('không có ảnh thì không upload, images rỗng', () async {
    final repo = _FakeRepo();
    final notifier = _notifier(repo);

    final ok = await notifier.submit(_params());

    expect(ok, isTrue);
    expect(repo.uploadCount, 0);
    expect(repo.submittedImages, isEmpty);
  });

  test('upload ảnh lỗi thì KHÔNG gửi đánh giá', () async {
    final repo = _FakeRepo()..uploadFailure = const ServerFailure(message: 'lỗi mạng');
    final notifier = _notifier(repo);

    final ok = await notifier.submit(
      _params(),
      photos: const [UploadReviewImageParams(bytes: [1], filename: 'a.jpg')],
    );

    expect(ok, isFalse);
    expect(repo.submittedImages, isNull); // submitReview không được gọi
    expect(notifier.errorMessage, 'lỗi mạng');
  });
}
