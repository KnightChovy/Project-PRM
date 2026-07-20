import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_history_item.dart';
import 'package:smart_stay_ai/features/booking/domain/repositories/booking_history_repository.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/cancel_booking.dart';

/// Fake repository tự viết (không dùng mocktail để khỏi thêm thư viện).
class _FakeBookingHistoryRepository implements BookingHistoryRepository {
  String? lastCancelledId;
  bool shouldFail = false;

  @override
  Future<Either<Failure, List<BookingHistoryItem>>> getHistory() async =>
      const Right([]);

  @override
  Future<Either<Failure, Unit>> cancelBooking(String id) async {
    lastCancelledId = id;
    if (shouldFail) {
      return const Left(ServerFailure(message: 'server error'));
    }
    return const Right(unit);
  }
}

void main() {
  group('CancelBooking use case', () {
    test('trả về Failure khi id rỗng và KHÔNG gọi repository', () async {
      final repo = _FakeBookingHistoryRepository();
      final usecase = CancelBooking(repo);

      final result = await usecase(const CancelBookingParams('   '));

      expect(result.isLeft(), isTrue);
      expect(repo.lastCancelledId, isNull);
    });

    test('gọi repository với id hợp lệ và trả về Right', () async {
      final repo = _FakeBookingHistoryRepository();
      final usecase = CancelBooking(repo);

      final result = await usecase(const CancelBookingParams('bk_amanoi'));

      expect(result.isRight(), isTrue);
      expect(repo.lastCancelledId, 'bk_amanoi');
    });

    test('truyền Failure lên khi repository báo lỗi', () async {
      final repo = _FakeBookingHistoryRepository()..shouldFail = true;
      final usecase = CancelBooking(repo);

      final result = await usecase(const CancelBookingParams('bk_x'));

      expect(result.isLeft(), isTrue);
    });
  });
}
