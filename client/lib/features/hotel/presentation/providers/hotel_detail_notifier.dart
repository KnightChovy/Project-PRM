import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/hotel/domain/entities/hotel.dart';
import 'package:smart_stay_ai/features/hotel/domain/usecases/get_hotel_detail.dart';

enum HotelDetailStatus { initial, loading, loaded, error }

/// Quản lý chi tiết MỘT khách sạn (amenities + toàn bộ ảnh + giá). Đăng ký
/// FACTORY để mỗi trang chi tiết là một phiên riêng.
class HotelDetailNotifier extends ChangeNotifier with SafeNotifier {
  final GetHotelDetail getHotelDetail;
  HotelDetailNotifier(this.getHotelDetail);

  HotelDetailStatus status = HotelDetailStatus.initial;
  Hotel? hotel;
  String? errorMessage;

  bool get isLoading => status == HotelDetailStatus.loading;

  /// [fallback] là hotel tối giản từ danh sách (hiển thị tạm trong lúc tải chi
  /// tiết đầy đủ từ API).
  Future<void> load(String hotelId, {Hotel? fallback}) async {
    status = HotelDetailStatus.loading;
    hotel = fallback;
    errorMessage = null;
    safeNotifyListeners();

    final result = await getHotelDetail(hotelId);
    result.fold(
      (failure) {
        status = HotelDetailStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = HotelDetailStatus.loaded;
        hotel = data;
      },
    );
    safeNotifyListeners();
  }
}
