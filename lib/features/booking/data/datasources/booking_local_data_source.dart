import '../../domain/entities/booking.dart';

/// Kho lưu đặt phòng TẠM trong bộ nhớ (RAM).
/// Phải đăng ký là singleton ở DI để dữ liệu còn giữ giữa các màn.
///
/// NOTE: khi có backend, thay bằng BookingRemoteDataSource gọi API.
class BookingLocalDataSource {
  final List<Booking> _items = [];

  /// Thêm 1 booking (mới nhất lên đầu).
  Booking add(Booking booking) {
    _items.insert(0, booking);
    return booking;
  }

  /// Lấy toàn bộ booking (bản sao chỉ-đọc).
  List<Booking> getAll() => List.unmodifiable(_items);
}
