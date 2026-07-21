import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/review/domain/entities/review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/get_my_reviews.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/upload_review_image.dart';

enum ReviewStatus { initial, submitting, success, error }

/// Quản lý trạng thái màn "Write Review". Chỉ gọi UseCase, không gọi
/// repository trực tiếp; không đụng BuildContext/widget.
class ReviewNotifier extends ChangeNotifier with SafeNotifier {
  final SubmitReview submitReview;
  final GetMyReviews getMyReviews;
  final UploadReviewImage uploadReviewImage;
  ReviewNotifier(this.submitReview, this.getMyReviews, this.uploadReviewImage);

  ReviewStatus status = ReviewStatus.initial;
  Review? submitted;
  String? errorMessage;

  /// Đánh giá đã có sẵn cho chỗ đang xem (nếu khách từng đánh giá rồi).
  /// Khác null => hiển thị chế độ chỉ-đọc, chặn đánh giá lại.
  Review? existing;

  bool get isSubmitting => status == ReviewStatus.submitting;

  /// Kiểm tra khách đã từng đánh giá booking [bookingId] chưa
  /// (mỗi booking chỉ 1 review theo API).
  Future<void> checkExisting(String bookingId) async {
    final result = await getMyReviews(const NoParams());
    result.fold((_) {}, (reviews) {
      for (final r in reviews) {
        if (r.bookingId == bookingId) {
          existing = r;
          break;
        }
      }
    });
    safeNotifyListeners();
  }

  /// Gửi đánh giá. Trả về true nếu thành công (để widget điều hướng/snackbar).
  ///
  /// [photos] (nếu có) được tải lên `/uploads` TRƯỚC, rồi đính URL vào đánh giá.
  /// Ảnh nào tải lỗi thì dừng luôn, không gửi đánh giá thiếu ảnh.
  Future<bool> submit(
    SubmitReviewParams params, {
    List<UploadReviewImageParams> photos = const [],
  }) async {
    status = ReviewStatus.submitting;
    errorMessage = null;
    safeNotifyListeners();

    final urls = <String>[];
    for (final photo in photos) {
      final uploaded = await uploadReviewImage(photo);
      final failed = uploaded.fold(
        (failure) {
          status = ReviewStatus.error;
          errorMessage = failure.message;
          safeNotifyListeners();
          return true;
        },
        (url) {
          urls.add(url);
          return false;
        },
      );
      if (failed) return false;
    }

    final result = await submitReview(params.copyWith(images: urls));
    return result.fold(
      (failure) {
        status = ReviewStatus.error;
        errorMessage = failure.message;
        safeNotifyListeners();
        return false;
      },
      (review) {
        status = ReviewStatus.success;
        submitted = review;
        existing = review; // chặn đánh giá lại ngay sau khi gửi
        safeNotifyListeners();
        return true;
      },
    );
  }
}
