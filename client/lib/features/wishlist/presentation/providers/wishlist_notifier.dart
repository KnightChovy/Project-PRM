import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/wishlist/domain/usecases/get_wishlist.dart';
import 'package:smart_stay_ai/features/wishlist/domain/usecases/toggle_wishlist.dart';

enum WishlistStatus { initial, loading, loaded, error }

/// Quản lý wishlist (lưu LOCAL). Đăng ký SINGLETON để trái tim ở trang chi tiết,
/// thẻ khách sạn và tab Wishlist luôn đồng bộ với nhau.
class WishlistNotifier extends ChangeNotifier with SafeNotifier {
  final GetWishlist getWishlist;
  final ToggleWishlist toggleWishlist;
  WishlistNotifier(this.getWishlist, this.toggleWishlist);

  WishlistStatus status = WishlistStatus.initial;
  List<Hotel> hotels = const [];
  String? errorMessage;

  bool get isLoading => status == WishlistStatus.loading;

  /// Khách sạn [id] có đang được lưu không.
  bool isSaved(String id) => hotels.any((h) => h.id == id);

  Future<void> load() async {
    status = WishlistStatus.loading;
    errorMessage = null;
    safeNotifyListeners();

    final result = await getWishlist(const NoParams());
    result.fold(
      (failure) {
        status = WishlistStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = WishlistStatus.loaded;
        hotels = data;
      },
    );
    safeNotifyListeners();
  }

  /// Bật/tắt lưu một khách sạn. Cập nhật danh sách theo kết quả từ local.
  Future<void> toggle(Hotel hotel) async {
    final result = await toggleWishlist(hotel);
    result.fold(
      (failure) {
        errorMessage = failure.message;
      },
      (data) {
        status = WishlistStatus.loaded;
        hotels = data;
      },
    );
    safeNotifyListeners();
  }
}
