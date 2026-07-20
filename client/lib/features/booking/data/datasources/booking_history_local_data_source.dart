import 'package:smart_stay_ai/core/error/exceptions.dart';
import '../../domain/entities/booking.dart';

/// Kho lịch sử đặt phòng TẠM trong RAM, có sẵn dữ liệu mẫu để demo 3 tab
/// (Upcoming / Completed / Cancelled).
///
/// NOTE: đây là dữ liệu MOCK độc lập với [BookingLocalDataSource] của tầng
/// tạo booking (giữ nguyên, không sửa). Khi có backend, thay bằng
/// BookingHistoryRemoteDataSource gọi GET /bookings và DELETE /bookings/:id.
abstract interface class BookingHistoryLocalDataSource {
  List<Booking> getBookings();
  Set<String> getCancelledIds();
  Future<void> cancel(String id);
}

class BookingHistoryLocalDataSourceImpl
    implements BookingHistoryLocalDataSource {
  BookingHistoryLocalDataSourceImpl() {
    _seed();
  }

  final List<Booking> _items = [];
  final Set<String> _cancelledIds = {};

  /// Sinh 3 booking mẫu với ngày tương đối so với hôm nay để 3 tab luôn có dữ
  /// liệu, bất kể chạy app vào thời điểm nào.
  void _seed() {
    final now = DateTime.now();

    _items.addAll([
      // Sắp tới (Upcoming)
      Booking(
        id: 'bk_amanoi',
        code: 'SS-92841',
        hotelName: 'Amanoi Resort',
        location: 'Vinh Hy Bay, Ninh Thuan, Vietnam',
        roomName: 'Deluxe Ocean View',
        imageUrl:
            'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        guestName: 'Alex Rivera',
        checkIn: now.add(const Duration(days: 40)),
        checkOut: now.add(const Duration(days: 43)),
        checkInTime: '3:00 PM',
        checkOutTime: '12:00 PM',
        adults: 2,
        children: 0,
        subtotal: 1200,
        taxes: 120,
        discount: 132,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      // Đã hoàn tất (Completed)
      Booking(
        id: 'bk_sixsenses',
        code: 'SS-77310',
        hotelName: 'Six Senses Ninh Van Bay',
        location: 'Nha Trang, Vietnam',
        roomName: 'Beachfront Pool Villa',
        imageUrl:
            'https://images.unsplash.com/photo-1610641818989-c2051b5e2cfd?w=800',
        guestName: 'Alex Rivera',
        checkIn: now.subtract(const Duration(days: 90)),
        checkOut: now.subtract(const Duration(days: 85)),
        checkInTime: '2:00 PM',
        checkOutTime: '12:00 PM',
        adults: 2,
        children: 0,
        subtotal: 2400,
        taxes: 200,
        discount: 0,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      // Đã huỷ (Cancelled)
      Booking(
        id: 'bk_parkhyatt',
        code: 'SS-66020',
        hotelName: 'Park Hyatt Saigon',
        location: 'Ho Chi Minh City, Vietnam',
        roomName: 'Park Suite',
        imageUrl:
            'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
        guestName: 'Alex Rivera',
        checkIn: now.subtract(const Duration(days: 20)),
        checkOut: now.subtract(const Duration(days: 18)),
        checkInTime: '3:00 PM',
        checkOutTime: '12:00 PM',
        adults: 1,
        children: 0,
        subtotal: 450,
        taxes: 40,
        discount: 0,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ]);
    _cancelledIds.add('bk_parkhyatt');
  }

  @override
  List<Booking> getBookings() => List.unmodifiable(_items);

  @override
  Set<String> getCancelledIds() => Set.unmodifiable(_cancelledIds);

  @override
  Future<void> cancel(String id) async {
    if (id.trim().isEmpty) {
      throw ServerException(message: 'Thiếu mã booking để huỷ.');
    }
    // Chỉ cần ghi id vào tập đã-huỷ. Áp dụng cho cả booking mẫu (seeded) lẫn
    // booking thật từ luồng đặt phòng của Phat (id nằm ở kho khác, không có
    // trong _items) — vì getHistory đã suy trạng thái theo tập này.
    _cancelledIds.add(id);
  }
}
