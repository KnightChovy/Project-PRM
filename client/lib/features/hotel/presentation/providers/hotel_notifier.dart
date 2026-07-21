import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/hotel/domain/usecases/search_hotels.dart';

enum HotelStatus { initial, loading, loaded, error }

/// Quản lý danh sách khách sạn cho Home / Search / Map. Đăng ký SINGLETON để
/// các màn dùng chung danh sách đã tải (khỏi gọi API lặp).
class HotelNotifier extends ChangeNotifier with SafeNotifier {
  final SearchHotels searchHotels;
  HotelNotifier(this.searchHotels);

  HotelStatus status = HotelStatus.initial;
  List<Hotel> hotels = const [];
  String? errorMessage;

  bool get isLoading => status == HotelStatus.loading;

  /// Tải danh sách khách sạn (bỏ trống city = tất cả).
  Future<void> load({String? city}) async {
    status = HotelStatus.loading;
    errorMessage = null;
    safeNotifyListeners();

    final result =
        await searchHotels(SearchHotelsParams(city: city, limit: 50));
    result.fold(
      (failure) {
        status = HotelStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = HotelStatus.loaded;
        hotels = data;
      },
    );
    safeNotifyListeners();
  }
}
