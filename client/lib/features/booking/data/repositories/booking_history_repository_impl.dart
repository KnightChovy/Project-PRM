import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/booking_history_item.dart';
import '../../domain/repositories/booking_history_repository.dart';
import '../datasources/booking_history_local_data_source.dart';
import '../datasources/booking_local_data_source.dart';

/// Hiện thực [BookingHistoryRepository]. NƠI DUY NHẤT đổi Exception → Failure.
///
/// Gộp 2 nguồn (cùng feature `booking`):
///  - [bookingLocal]: booking THẬT do người dùng đặt qua luồng của Phat.
///  - [historyLocal]: dữ liệu mẫu seeded + tập id đã huỷ (của BinhKhiem).
class BookingHistoryRepositoryImpl implements BookingHistoryRepository {
  final BookingHistoryLocalDataSource historyLocal;
  final BookingLocalDataSource bookingLocal;
  const BookingHistoryRepositoryImpl(this.historyLocal, this.bookingLocal);

  @override
  Future<Either<Failure, List<BookingHistoryItem>>> getHistory() async {
    try {
      final cancelled = historyLocal.getCancelledIds();
      final now = DateTime.now();
      // Booking thật (mới nhất ở trên) + dữ liệu mẫu để 3 tab luôn có nội dung.
      final all = <Booking>[
        ...bookingLocal.getAll(),
        ...historyLocal.getBookings(),
      ];
      final items = all.map((b) {
        // Quy tắc suy ra trạng thái: đã huỷ > đã qua ngày trả phòng > sắp tới.
        final BookingLifecycle status;
        if (cancelled.contains(b.id)) {
          status = BookingLifecycle.cancelled;
        } else if (b.checkOut.isBefore(now)) {
          status = BookingLifecycle.completed;
        } else {
          status = BookingLifecycle.upcoming;
        }
        return BookingHistoryItem(booking: b, status: status);
      }).toList();
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelBooking(String id) async {
    try {
      await historyLocal.cancel(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
