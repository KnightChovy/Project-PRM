import 'package:equatable/equatable.dart';
import 'booking.dart';

/// Vòng đời của một lượt đặt phòng (dùng để chia tab trong "My Bookings").
enum BookingLifecycle { upcoming, completed, cancelled }

/// Một dòng trong lịch sử đặt phòng: gắn [Booking] với trạng thái đã suy ra.
///
/// Tách riêng với entity [Booking] (của tầng tạo booking) để KHÔNG phải sửa
/// entity gốc — chỉ bọc thêm thông tin trạng thái phục vụ màn lịch sử.
class BookingHistoryItem extends Equatable {
  final Booking booking;
  final BookingLifecycle status;

  const BookingHistoryItem({required this.booking, required this.status});

  bool get isCancelled => status == BookingLifecycle.cancelled;
  bool get isCompleted => status == BookingLifecycle.completed;
  bool get isUpcoming => status == BookingLifecycle.upcoming;

  @override
  List<Object?> get props => [booking, status];
}
