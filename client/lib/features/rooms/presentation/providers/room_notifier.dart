import 'package:flutter/foundation.dart';
import 'package:smart_stay_ai/core/utils/safe_notifier.dart';
import 'package:smart_stay_ai/features/rooms/domain/entities/room.dart';
import 'package:smart_stay_ai/features/rooms/domain/usecases/get_room_types.dart';

enum RoomStatus { initial, loading, loaded, error }

/// Quản lý danh sách loại phòng của MỘT khách sạn. Đăng ký FACTORY để mỗi màn
/// danh sách phòng là một phiên riêng (gắn với hotelId khác nhau).
class RoomNotifier extends ChangeNotifier with SafeNotifier {
  final GetRoomTypes getRoomTypes;
  RoomNotifier(this.getRoomTypes);

  RoomStatus status = RoomStatus.initial;
  List<Room> rooms = const [];
  String? errorMessage;

  bool get isLoading => status == RoomStatus.loading;

  /// Tải danh sách loại phòng của khách sạn [hotelId].
  Future<void> load(String hotelId) async {
    status = RoomStatus.loading;
    errorMessage = null;
    safeNotifyListeners();

    final result = await getRoomTypes(hotelId);
    result.fold(
      (failure) {
        status = RoomStatus.error;
        errorMessage = failure.message;
      },
      (data) {
        status = RoomStatus.loaded;
        rooms = data;
      },
    );
    safeNotifyListeners();
  }
}
