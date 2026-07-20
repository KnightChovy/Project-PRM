import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/error/failures.dart';
import 'package:smart_stay_ai/core/utils/money.dart';
import 'package:smart_stay_ai/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:smart_stay_ai/features/booking/data/models/checkout_model.dart';
import 'package:smart_stay_ai/features/booking/data/models/booking_model.dart';
import 'package:smart_stay_ai/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/checkout.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/paginated.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_status.dart';

BookingModel _booking() => BookingModel(
      id: 'b-1',
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
      status: BookingStatus.pending,
      source: 'website',
      createdAt: DateTime.utc(2026, 7, 20),
    );

/// Fake datasource tự viết (dự án không dùng mocktail).
class _FakeRemote implements BookingRemoteDataSource {
  /// Exception mà mọi hàm sẽ ném ra; null nghĩa là trả dữ liệu thành công.
  Exception? throws;

  RefundDestination? capturedDestination;

  T _run<T>(T value) {
    final error = throws;
    if (error != null) throw error;
    return value;
  }

  @override
  Future<BookingModel> create({
    required String hotelId,
    required String roomTypeId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numGuests,
    String? specialRequests,
    required PaymentMethod paymentMethod,
  }) async =>
      _run(_booking());

  @override
  Future<Paginated<BookingModel>> getMine({
    BookingStatus? status,
    int? page,
    int? limit,
    String? sortBy,
  }) async =>
      _run(
        Paginated<BookingModel>(
          items: [_booking()],
          page: 1,
          limit: 20,
          totalPages: 3,
          totalResults: 45,
        ),
      );

  @override
  Future<BookingModel> getById(String bookingId) async => _run(_booking());

  @override
  Future<BookingModel> cancel({
    required String bookingId,
    required RefundDestination destination,
    String? reason,
  }) async {
    capturedDestination = destination;
    return _run(_booking());
  }

  @override
  Future<VnpayCheckoutModel> startVnpayCheckout(String bookingId) async =>
      _run(const VnpayCheckoutModel(paymentUrl: 'https://vnpay.test/pay'));

  @override
  Future<SepayCheckoutModel> startSepayCheckout(String bookingId) async => _run(
        SepayCheckoutModel(
          qrUrl: 'https://qr.sepay.vn/img',
          transferContent: 'SS-000001',
          amount: const Money('1130000'),
          accountNumber: '123',
          bankCode: 'VCB',
          expiresAt: DateTime.utc(2026, 7, 20, 10, 30),
        ),
      );

  @override
  Future<WalletPaymentResultModel> payWithWallet(String bookingId) async =>
      _run(
        const WalletPaymentResultModel(
          bookingCode: 'SS-000001',
          walletApplied: Money('500000'),
          remainingToPay: Money('630000'),
          bookingStatus: BookingStatus.pending,
          walletBalance: Money('0'),
        ),
      );
}

void main() {
  late _FakeRemote remote;
  late BookingRepositoryImpl repository;

  setUp(() {
    remote = _FakeRemote();
    repository = BookingRepositoryImpl(remote);
  });

  group('đổi Exception -> Failure', () {
    test('ValidationException (400) -> ValidationFailure, giữ message server',
        () async {
      remote.throws =
          const ValidationException(message: 'Đã hết phòng đêm 2026-08-02');

      final result = await repository.getById('b-1');

      expect(
        result,
        const Left<Failure, Booking>(
          ValidationFailure(message: 'Đã hết phòng đêm 2026-08-02'),
        ),
      );
    });

    test('UnauthorizedException (401) -> AuthFailure', () async {
      remote.throws = const UnauthorizedException(message: 'Hết hạn đăng nhập');

      final result = await repository.getById('b-1');

      expect(result.getLeft().toNullable(), isA<AuthFailure>());
    });

    test('NotFoundException (404) -> NotFoundFailure', () async {
      remote.throws = const NotFoundException(
        message: 'Không tìm thấy loại phòng trong khách sạn này',
      );

      final result = await repository.getById('b-1');

      expect(result.getLeft().toNullable(), isA<NotFoundFailure>());
    });

    test('NetworkException -> NetworkFailure', () async {
      remote.throws = const NetworkException(message: 'Không có kết nối mạng');

      final result = await repository.getById('b-1');

      expect(result.getLeft().toNullable(), isA<NetworkFailure>());
    });

    test('ServerException -> ServerFailure', () async {
      remote.throws = const ServerException(message: 'Lỗi máy chủ');

      final result = await repository.getById('b-1');

      expect(result.getLeft().toNullable(), isA<ServerFailure>());
    });
  });

  group('đường thành công', () {
    test('create trả về Booking', () async {
      final result = await repository.create(
        hotelId: 'h-1',
        roomTypeId: 'rt-1',
        checkInDate: DateTime.utc(2026, 8, 1),
        checkOutDate: DateTime.utc(2026, 8, 3),
        numGuests: 2,
      );

      expect(result.toNullable()?.bookingCode, 'SS-000001');
    });

    test('getMine giữ nguyên thông tin phân trang', () async {
      final result = await repository.getMine(limit: 20);
      final paged = result.toNullable()!;

      expect(paged.items, hasLength(1));
      expect(paged.totalResults, 45);
      expect(paged.totalPages, 3);
      expect(paged.hasNextPage, isTrue);
    });

    test('cancel chuyển tiếp đúng nơi nhận tiền hoàn', () async {
      await repository.cancel(
        bookingId: 'b-1',
        destination: const BankRefund(
          BankAccount(
            accountNumber: '123',
            bankName: 'VCB',
            accountHolder: 'NGUYEN VAN A',
          ),
        ),
      );

      expect(remote.capturedDestination, isA<BankRefund>());
    });

    test('payWithWallet báo còn thiếu tiền khi ví không đủ', () async {
      final result = await repository.payWithWallet('b-1');
      final wallet = result.toNullable()!;

      expect(wallet.isFullyPaid, isFalse);
      expect(wallet.remainingToPay.raw, '630000');
    });
  });
}
