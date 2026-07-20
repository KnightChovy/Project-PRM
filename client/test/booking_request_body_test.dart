import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import 'package:smart_stay_ai/core/network/token_storage.dart';
import 'package:smart_stay_ai/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/checkout.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_status.dart';

/// Chặn request ở tầng adapter để soi đúng những gì được gửi lên, và trả về
/// body giả — không chạm mạng thật.
class _RecordingAdapter implements HttpClientAdapter {
  RequestOptions? captured;
  final Object responseBody;
  final int statusCode;

  _RecordingAdapter({required this.responseBody, this.statusCode = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode(responseBody),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _bookingJson() => {
      'id': 'b-1',
      'bookingCode': 'SS-000001',
      'customerId': 'c-1',
      'hotelId': 'h-1',
      'roomTypeId': 'rt-1',
      'checkInDate': '2026-08-01T00:00:00.000Z',
      'checkOutDate': '2026-08-03T00:00:00.000Z',
      'numNights': 2,
      'numGuests': 2,
      'basePricePerNight': '500000',
      'subtotal': '1000000',
      'discountAmount': '0',
      'taxAmount': '80000',
      'feeAmount': '50000',
      'totalAmount': '1130000',
      'status': 'pending',
      'source': 'website',
      'createdAt': '2026-07-20T10:00:00.000Z',
      'payments': const [],
    };

Future<(BookingRemoteDataSourceImpl, _RecordingAdapter)> _build({
  required Object responseBody,
  int statusCode = 200,
}) async {
  // BASE_URL đã được nạp sẵn ở test/flutter_test_config.dart.
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final client = DioClient(TokenStorage(prefs));
  final adapter =
      _RecordingAdapter(responseBody: responseBody, statusCode: statusCode);
  client.dio.httpClientAdapter = adapter;
  return (BookingRemoteDataSourceImpl(client), adapter);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('POST /bookings', () {
    test('gửi ngày dạng yyyy-MM-dd và KHÔNG gửi bất kỳ field giá nào', () async {
      final (dataSource, adapter) = await _build(responseBody: _bookingJson());

      await dataSource.create(
        hotelId: 'h-1',
        roomTypeId: 'rt-1',
        checkInDate: DateTime(2026, 8, 1),
        checkOutDate: DateTime(2026, 8, 3),
        numGuests: 2,
        paymentMethod: PaymentMethod.vnpay,
      );

      final body = adapter.captured!.data as Map<String, dynamic>;

      expect(body['checkInDate'], '2026-08-01');
      expect(body['checkOutDate'], '2026-08-03');
      expect(body['paymentMethod'], 'vnpay');
      expect(body['numGuests'], 2);

      // Server tự tính tiền; gửi giá lên là bị Joi reject 400.
      for (final priceField in [
        'price',
        'subtotal',
        'totalAmount',
        'basePricePerNight',
        'taxAmount',
        'feeAmount',
      ]) {
        expect(body.containsKey(priceField), isFalse,
            reason: 'không được gửi $priceField');
      }
    });

    test('bỏ qua specialRequests khi rỗng', () async {
      final (dataSource, adapter) = await _build(responseBody: _bookingJson());

      await dataSource.create(
        hotelId: 'h-1',
        roomTypeId: 'rt-1',
        checkInDate: DateTime(2026, 8, 1),
        checkOutDate: DateTime(2026, 8, 3),
        numGuests: 2,
        specialRequests: '   ',
        paymentMethod: PaymentMethod.cash,
      );

      final body = adapter.captured!.data as Map<String, dynamic>;
      expect(body.containsKey('specialRequests'), isFalse);
      expect(body['paymentMethod'], 'cash');
    });

    test('giữ nguyên message tiếng Việt của server khi 400', () async {
      final (dataSource, _) = await _build(
        responseBody: {
          'code': 400,
          'message': 'Đã hết phòng đêm 2026-08-02',
        },
        statusCode: 400,
      );

      expect(
        () => dataSource.create(
          hotelId: 'h-1',
          roomTypeId: 'rt-1',
          checkInDate: DateTime(2026, 8, 1),
          checkOutDate: DateTime(2026, 8, 3),
          numGuests: 2,
          paymentMethod: PaymentMethod.vnpay,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Đã hết phòng đêm 2026-08-02',
          ),
        ),
      );
    });
  });

  group('PATCH /bookings/{id}/cancel', () {
    test('hoàn về ví thì TUYỆT ĐỐI không gửi bankAccount', () async {
      final (dataSource, adapter) = await _build(responseBody: _bookingJson());

      await dataSource.cancel(
        bookingId: 'b-1',
        destination: const WalletRefund(),
        reason: 'Đổi lịch',
      );

      final body = adapter.captured!.data as Map<String, dynamic>;
      expect(body['refundMethod'], 'wallet');
      // Joi đánh dấu forbidden -> gửi kèm là ăn 400.
      expect(body.containsKey('bankAccount'), isFalse);
      expect(body['reason'], 'Đổi lịch');
    });

    test('hoàn về ngân hàng thì gửi kèm đủ thông tin tài khoản', () async {
      final (dataSource, adapter) = await _build(responseBody: _bookingJson());

      await dataSource.cancel(
        bookingId: 'b-1',
        destination: const BankRefund(
          BankAccount(
            accountNumber: '0123456789',
            bankName: 'Vietcombank',
            accountHolder: 'NGUYEN VAN A',
          ),
        ),
      );

      final body = adapter.captured!.data as Map<String, dynamic>;
      expect(body['refundMethod'], 'bank');
      expect(body['bankAccount'], {
        'accountNumber': '0123456789',
        'bankName': 'Vietcombank',
        'accountHolder': 'NGUYEN VAN A',
      });
    });
  });

  group('GET /bookings/me', () {
    test('map trạng thái sang dạng snake_case khi lọc', () async {
      final (dataSource, adapter) = await _build(
        responseBody: {
          'results': [_bookingJson()],
          'page': 1,
          'limit': 20,
          'totalPages': 1,
          'totalResults': 1,
        },
      );

      await dataSource.getMine(status: BookingStatus.checkedIn, page: 2);

      final query = adapter.captured!.queryParameters;
      expect(query['status'], 'checked_in');
      expect(query['page'], 2);
      // Tham số không truyền thì không được xuất hiện trong query.
      expect(query.containsKey('limit'), isFalse);
      expect(query.containsKey('sortBy'), isFalse);
    });

    test('đọc được envelope phân trang', () async {
      final (dataSource, _) = await _build(
        responseBody: {
          'results': [_bookingJson()],
          'page': 2,
          'limit': 20,
          'totalPages': 5,
          'totalResults': 91,
        },
      );

      final paged = await dataSource.getMine();

      expect(paged.items, hasLength(1));
      expect(paged.page, 2);
      expect(paged.totalResults, 91);
      expect(paged.hasNextPage, isTrue);
    });

    test('vẫn đọc được khi API trả mảng trần', () async {
      final (dataSource, _) = await _build(responseBody: [_bookingJson()]);

      final paged = await dataSource.getMine();

      expect(paged.items, hasLength(1));
      expect(paged.totalResults, 1);
    });
  });

  group('payments', () {
    test('SePay đọc được amount dạng number', () async {
      final (dataSource, _) = await _build(
        responseBody: {
          'qrUrl': 'https://qr.sepay.vn/img?x=1',
          'transferContent': 'SS-000001',
          'amount': 1130000,
          'accountNumber': '0123456789',
          'bankCode': 'VCB',
          'expiresAt': '2026-07-20T10:30:00.000Z',
        },
      );

      final checkout = await dataSource.startSepayCheckout('b-1');

      expect(checkout.transferContent, 'SS-000001');
      expect(checkout.amount.amountAsInt, 1130000);
      expect(checkout.qrUrl, 'https://qr.sepay.vn/img?x=1');
    });

    test('ví trả một phần thì còn remainingToPay', () async {
      final (dataSource, _) = await _build(
        responseBody: {
          'bookingCode': 'SS-000001',
          'walletApplied': '500000',
          'remainingToPay': '630000',
          'bookingStatus': 'pending',
          'voucherCode': null,
          'walletBalance': '0',
        },
      );

      final wallet = await dataSource.payWithWallet('b-1');

      expect(wallet.isFullyPaid, isFalse);
      expect(wallet.remainingToPay.raw, '630000');
      expect(wallet.bookingStatus, BookingStatus.pending);
    });
  });
}
