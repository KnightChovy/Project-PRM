import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

/// Use case: gửi một đánh giá.
///
/// Quy tắc nghiệp vụ: bắt buộc phải chọn điểm tổng (overall >= 1) thì mới
/// được gửi. Kiểm tra này nằm ở Domain để mọi nơi gọi đều an toàn.
class SubmitReview implements UseCase<Review, SubmitReviewParams> {
  final ReviewRepository repository;
  const SubmitReview(this.repository);

  @override
  Future<Either<Failure, Review>> call(SubmitReviewParams params) {
    if (params.overall < 1) {
      return Future.value(
        const Left(ValidationFailure(message: 'Vui lòng chọn số sao tổng quan.')),
      );
    }
    return repository.submitReview(
      bookingId: params.bookingId,
      overall: params.overall,
      cleanliness: params.cleanliness,
      locationRating: params.locationRating,
      service: params.service,
      value: params.value,
      comment: params.comment,
      title: params.title,
    );
  }
}

class SubmitReviewParams extends Equatable {
  final String bookingId;
  final int overall;
  final int cleanliness;
  final int locationRating;
  final int service;
  final int value;
  final String comment;
  final String? title;

  const SubmitReviewParams({
    required this.bookingId,
    required this.overall,
    required this.cleanliness,
    required this.locationRating,
    required this.service,
    required this.value,
    required this.comment,
    this.title,
  });

  @override
  List<Object?> get props => [
        bookingId,
        overall,
        cleanliness,
        locationRating,
        service,
        value,
        comment,
        title,
      ];
}
