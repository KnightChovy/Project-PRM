import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/utils/money.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/checkout.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/paginated.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_status.dart';
import 'package:smart_stay_ai/features/booking/domain/repositories/booking_repository.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/cancel_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/create_booking.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/get_booking_detail.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/pay_with_wallet.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/start_sepay_checkout.dart';
import 'package:smart_stay_ai/features/booking/domain/usecases/start_vnpay_checkout.dart';
import 'package:smart_stay_ai/features/booking/presentation/providers/booking_notifier.dart';

Booking _booking({
  BookingStatus status = BookingStatus.pending,
  String id = 'b-1',
}) =>
    Booking(
      id: id,
      bookingCode: 'SS-000001',
      customerId: 'c-1',
      hotelId: 'h-1',
      roomTypeId: 'rt-1',
      checkInDate: DateTime.utc(2026, 8, 1),
      checkOutDate: DateTime.utc(2026, 8, 3),
      numNights: 2,
      numGuests: 2,
      basePricePerNight: const Money('500000'),
      subtotal: const Money('1000000'),
      discountAmount: Money.zero,
      taxAmount: const Money('80000'),
      feeAmount: const Money('50000'),
      totalAmount: const Money('1130000'),
      status: status,
      source: 'website',
      createdAt: DateTime.utc(2026, 7, 20),
    );

/// Fake repository tự viết (dự án không dùng mocktail).
class _FakeRepository implements BookingRepository {
  Failure? failure;
  Booking detail = _booking();
  WalletPaymentResult wallet = const WalletPaymentResult(
    bookingCode: 'SS-000001',
    walletApplied: Money('500000'),
    remainingToPay: Money('630000'),
    bookingStatus: BookingStatus.pending,
    walletBalance: Money('0'),
  );

  int getByIdCalls = 0;

  Either<Failure, T> _result<T>(T value) {
    final error = failure;
    return error != null ? Left(error) : Right(value);
  }

  @override
  Future<Either<Failure, Booking>> create({
    required String hotelId,
    required String roomTypeId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numGuests,
    String? specialRequests,
    PaymentMethod paymentMethod = PaymentMethod.vnpay,
  }) async =>
      _result(_booking());

  @override
  Future<Either<Failure, Paginated<Booking>>> getMine({
    BookingStatus? status,
    int? page,
    int? limit,
    String? sortBy,
  }) async =>
      _result(
        Paginated<Booking>(
          items: [_booking()],
          page: 1,
          limit: 20,
          totalPages: 1,
          totalResults: 1,
        ),
      );

  @override
  Future<Either<Failure, Booking>> getById(String bookingId) async {
    getByIdCalls++;
    return _result(detail);
  }

  @override
  Future<Either<Failure, Booking>> cancel({
    required String bookingId,
    required RefundDestination destination,
    String? reason,
  }) async =>
      _result(_booking(status: BookingStatus.cancelled));

  @override
  Future<Either<Failure, VnpayCheckout>> startVnpayCheckout(
    String bookingId,
  ) async =>
      _result(const VnpayCheckout(paymentUrl: 'https://vnpay.test/pay'));

  @override
  Future<Either<Failure, SepayCheckout>> startSepayCheckout(
    String bookingId,
  ) async =>
      _result(
        SepayCheckout(
          qrUrl: 'https://qr.sepay.vn/img',
          transferContent: 'SS-000001',
          amount: const Money('1130000'),
          accountNumber: '123',
          bankCode: 'VCB',
          // Đã quá hạn -> vòng poll đầu tiên tự dừng, test không treo.
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      );

  @override
  Future<Either<Failure, WalletPaymentResult>> payWithWallet(
    String bookingId,
  ) async =>
      _result(wallet);
}

BookingNotifier _notifier(_FakeRepository repo) => BookingNotifier(
      createBooking: CreateBooking(repo),
      getBookingDetail: GetBookingDetail(repo),
      startVnpayCheckout: StartVnpayCheckout(repo),
      startSepayCheckout: StartSepayCheckout(repo),
      payWithWallet: PayWithWallet(repo),
      cancelBooking: CancelBooking(repo),
    );

final _params = CreateBookingParams(
  hotelId: 'h-1',
  roomTypeId: 'rt-1',
  checkInDate: DateTime.utc(2026, 8, 1),
  checkOutDate: DateTime.utc(2026, 8, 3),
  numGuests: 2,
);

void main() {
  late _FakeRepository repo;
  late BookingNotifier notifier;

  setUp(() {
    repo = _FakeRepository();
    notifier = _notifier(repo);
  });

  tearDown(() => notifier.dispose());

  group('create', () {
    test('thành công thì giữ lại booking và chuyển sang success', () async {
      final booking = await notifier.create(_params);

      expect(booking, isNotNull);
      expect(notifier.status, RequestStatus.success);
      expect(notifier.booking?.bookingCode, 'SS-000001');
      expect(notifier.errorMessage, isNull);
    });

    test('thất bại thì trả null và giữ message tiếng Việt của server', () async {
      repo.failure = const ValidationFailure(
        message: 'Vui lòng cập nhật số điện thoại trong hồ sơ trước khi đặt phòng',
      );

      final booking = await notifier.create(_params);

      expect(booking, isNull);
      expect(notifier.status, RequestStatus.error);
      expect(
        notifier.errorMessage,
        'Vui lòng cập nhật số điện thoại trong hồ sơ trước khi đặt phòng',
      );
    });

    test('phát tín hiệu cho widget rebuild', () async {
      var notifications = 0;
      notifier.addListener(() => notifications++);

      await notifier.create(_params);

      // Ít nhất 2 lần: vào loading, rồi ra kết quả.
      expect(notifications, greaterThanOrEqualTo(2));
    });
  });

  group('thanh toán', () {
    test('chưa có booking thì không gọi được cổng thanh toán', () async {
      final url = await notifier.beginVnpayCheckout();

      expect(url, isNull);
      expect(notifier.status, RequestStatus.error);
      expect(notifier.errorMessage, 'Chưa có booking nào để thanh toán');
    });

    test('trả về link VNPay để widget tự mở', () async {
      await notifier.create(_params);

      final url = await notifier.beginVnpayCheckout();

      expect(url, 'https://vnpay.test/pay');
    });

    test('ví trả thiếu thì KHÔNG refresh, booking vẫn chờ trả tiếp', () async {
      await notifier.create(_params);
      final before = repo.getByIdCalls;

      final result = await notifier.payFromWallet();

      expect(result?.isFullyPaid, isFalse);
      expect(result?.remainingToPay.raw, '630000');
      expect(repo.getByIdCalls, before, reason: 'chưa trả đủ thì chưa cần tải lại');
    });

    test('ví trả đủ thì kéo lại booking để lấy trạng thái mới', () async {
      await notifier.create(_params);
      repo.wallet = const WalletPaymentResult(
        bookingCode: 'SS-000001',
        walletApplied: Money('1130000'),
        remainingToPay: Money('0'),
        bookingStatus: BookingStatus.confirmed,
        walletBalance: Money('0'),
        voucherCode: 'V-123',
      );
      repo.detail = _booking(status: BookingStatus.confirmed);
      final before = repo.getByIdCalls;

      final result = await notifier.payFromWallet();

      expect(result?.isFullyPaid, isTrue);
      expect(repo.getByIdCalls, before + 1);
      expect(notifier.booking?.status, BookingStatus.confirmed);
    });
  });

  group('cancel', () {
    test('huỷ xong thì cập nhật trạng thái booking đang giữ', () async {
      await notifier.create(_params);

      final cancelled = await notifier.cancel(
        destination: const WalletRefund(),
        reason: 'Đổi lịch',
      );

      expect(cancelled?.status, BookingStatus.cancelled);
      expect(notifier.booking?.status, BookingStatus.cancelled);
    });
  });

  group('refresh', () {
    test('không có id thì không gọi API', () async {
      final result = await notifier.refresh();

      expect(result, isNull);
      expect(repo.getByIdCalls, 0);
    });

    test('nguồn sự thật là server, không phải query param redirect về',
        () async {
      repo.detail = _booking(status: BookingStatus.confirmed);

      final result = await notifier.refresh('b-1');

      expect(result?.status, BookingStatus.confirmed);
      expect(notifier.booking?.status, BookingStatus.confirmed);
    });
  });
}
