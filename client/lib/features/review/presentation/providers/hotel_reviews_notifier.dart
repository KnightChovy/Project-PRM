import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/review/domain/entities/hotel_review.dart';
import 'package:smart_stay_ai/features/review/domain/usecases/get_hotel_reviews.dart';

enum HotelReviewsStatus { initial, loading, loaded, error }

/// Quản lý đánh giá CÔNG KHAI của một khách sạn (màn Guest Reviews). Đăng ký
/// FACTORY vì mỗi khách sạn là một phiên riêng.
class HotelReviewsNotifier extends ChangeNotifier with SafeNotifier {
  final GetHotelReviews getHotelReviews;
  HotelReviewsNotifier(this.getHotelReviews);

  HotelReviewsStatus status = HotelReviewsStatus.initial;
  List<HotelReview> reviews = const [];
  String? errorMessage;

  bool get isLoading => status == HotelReviewsStatus.loading;
  int get count => reviews.length;

  /// Điểm trung bình thực tế từ các đánh giá (0 nếu chưa có đánh giá nào).
  double get averageRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (a, r) => a + r.overall);
    return sum / reviews.length;
  }

  /// % trung bình theo từng tiêu chí (rating 1..5 → 20..100). Rỗng nếu chưa có.
  int cleanlinessPercent() => _avgPercent((r) => r.cleanliness);
  int locationPercent() => _avgPercent((r) => r.locationRating);
  int servicePercent() => _avgPercent((r) => r.service);
  int valuePercent() => _avgPercent((r) => r.value);

  int _avgPercent(int Function(HotelReview) pick) {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (a, r) => a + pick(r));
    return (sum / reviews.length * 20).round();
  }

  Future<void> load(String hotelId) async {
    status = HotelReviewsStatus.loading;
    errorMessage = null;
    safeNotifyListeners();

    final result = await getHotelReviews(hotelId);
    result.fold(
      (failure) {
        status = HotelReviewsStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = HotelReviewsStatus.loaded;
        reviews = data;
      },
    );
    safeNotifyListeners();
  }
}
