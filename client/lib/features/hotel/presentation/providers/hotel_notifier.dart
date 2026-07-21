import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/usecase/usecase.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/destination.dart';
import 'package:smart_stay_ai/features/hotel/domain/usecases/search_hotels.dart';
import 'package:smart_stay_ai/features/hotel/domain/usecases/get_destinations.dart';

enum HotelStatus { initial, loading, loaded, error }

/// Quản lý danh sách khách sạn + điểm đến cho Home / Search / Map. Đăng ký
/// SINGLETON để các màn dùng chung danh sách đã tải (khỏi gọi API lặp).
class HotelNotifier extends ChangeNotifier with SafeNotifier {
  final SearchHotels searchHotels;
  final GetDestinations getDestinations;
  HotelNotifier(this.searchHotels, this.getDestinations);

  HotelStatus status = HotelStatus.initial;
  List<Hotel> hotels = const [];

  /// Điểm đến phổ biến (Home). Lỗi tải điểm đến KHÔNG làm hỏng danh sách KS.
  List<Destination> destinations = const [];
  String? errorMessage;

  bool get isLoading => status == HotelStatus.loading;

  /// Tải danh sách khách sạn (bỏ trống city = tất cả) + điểm đến phổ biến.
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

    // Điểm đến tải song song, thất bại thì bỏ qua (giữ danh sách rỗng).
    final destResult = await getDestinations(const NoParams());
    destResult.fold((_) {}, (data) => destinations = data);

    safeNotifyListeners();
  }
}
