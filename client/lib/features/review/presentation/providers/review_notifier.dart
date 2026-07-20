import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/review/domain/entities/review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/get_my_reviews.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/submit_review.dart';

enum ReviewStatus { initial, submitting, success, error }

/// Quản lý trạng thái màn "Write Review". Chỉ gọi UseCase, không gọi
/// repository trực tiếp; không đụng BuildContext/widget.
class ReviewNotifier extends ChangeNotifier with SafeNotifier {
  final SubmitReview submitReview;
  final GetMyReviews getMyReviews;
  ReviewNotifier(this.submitReview, this.getMyReviews);

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
  Future<bool> submit(SubmitReviewParams params) async {
    status = ReviewStatus.submitting;
    errorMessage = null;
    safeNotifyListeners();

    final result = await submitReview(params);
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
