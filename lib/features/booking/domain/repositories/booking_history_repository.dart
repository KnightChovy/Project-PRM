import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../entities/booking_history_item.dart';

/// Hợp đồng cho lịch sử đặt phòng (xem danh sách + huỷ). Domain khai báo.
///
/// File MỚI, không đụng [BookingRepository] sẵn có của tầng tạo booking.
abstract interface class BookingHistoryRepository {
  /// Lấy toàn bộ lịch sử đặt phòng kèm trạng thái đã suy ra.
  Future<Either<Failure, List<BookingHistoryItem>>> getHistory();

  /// Huỷ một booking theo id. Trả về [unit] nếu thành công.
  Future<Either<Failure, Unit>> cancelBooking(String id);
}
