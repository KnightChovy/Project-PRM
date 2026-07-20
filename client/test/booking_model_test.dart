import 'package:flutter_test/flutter_test.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/features/booking/data/models/booking_model.dart';
import 'package:smart_stay_ai/features/booking/domain/entities/booking_status.dart';

Map<String, dynamic> _payload({
  String status = 'pending',
  Object? holdExpiresAt = '2026-07-20T10:15:00.000Z',
  Object? voucher,
  Object? payments,
}) {
  return {
    'id': 'b-1',
    'bookingCode': 'SS-XXXXXX',
    'customerId': 'c-1',
    'hotelId': '11111111-1111-1111-1111-111111111111',
    'roomTypeId': '22222222-2222-2222-2222-222222222222',
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
    'status': status,
    'source': 'website',
    'specialRequests': 'Phòng tầng cao',
    'holdExpiresAt': holdExpiresAt,
    'createdAt': '2026-07-20T10:00:00.000Z',
    'hotel': {
      'id': 'h-1',
      'name': 'SmartStay Sài Gòn',
      'address': '123 Lê Lợi',
      'city': 'Hồ Chí Minh',
      'checkInTime': '14:00',
      'checkOutTime': '12:00',
    },
    'roomType': {
      'id': 'rt-1',
      'name': 'Deluxe',
      'bedType': 'King',
      'viewType': 'City',
      'maxOccupancy': 2,
    },
    'voucher': voucher,
    'payments': payments ?? const [],
  };
}

void main() {
  group('BookingModel.fromJson', () {
    test('giữ nguyên chuỗi tiền, không parse sớm thành double', () {
      final booking = BookingModel.fromJson(_payload());

      expect(booking.subtotal.raw, '1000000');
      expect(booking.totalAmount.raw, '1130000');
      expect(booking.discountAmount.raw, '0');
      // Parse chỉ xảy ra khi cần tính/hiển thị.
      expect(booking.totalAmount.amount, 1130000.0);
      expect(booking.totalAmount.amountAsInt, 1130000);
      expect(booking.discountAmount.isZero, isTrue);
    });

    test('tổng tiền khớp công thức subtotal - discount + tax + fee', () {
      final booking = BookingModel.fromJson(_payload());

      final computed =
          booking.subtotal.amount -
          booking.discountAmount.amount +
          booking.taxAmount.amount +
          booking.feeAmount.amount;

      expect(computed, booking.totalAmount.amount);
    });

    test('ngày nhận/trả phòng giữ đúng thành phần ngày server gửi', () {
      final booking = BookingModel.fromJson(_payload());

      expect(booking.checkInDate.isUtc, isTrue);
      expect(booking.checkInDate.year, 2026);
      expect(booking.checkInDate.month, 8);
      expect(booking.checkInDate.day, 1);
      expect(booking.checkOutDate.day, 3);
      expect(booking.numNights, 2);
    });

    test('map đúng trạng thái dạng snake_case của API', () {
      expect(
        BookingModel.fromJson(_payload(status: 'checked_in')).status,
        BookingStatus.checkedIn,
      );
      expect(
        BookingModel.fromJson(_payload(status: 'no_show')).status,
        BookingStatus.noShow,
      );
    });

    test('ném ServerException khi gặp trạng thái lạ thay vì đoán bừa', () {
      expect(
        () => BookingModel.fromJson(_payload(status: 'something_new')),
        throwsA(isA<ServerException>()),
      );
    });

    test('đọc được thông tin khách sạn và loại phòng lồng bên trong', () {
      final booking = BookingModel.fromJson(_payload());

      expect(booking.hotel?.name, 'SmartStay Sài Gòn');
      expect(booking.hotel?.checkInTime, '14:00');
      expect(booking.roomType?.maxOccupancy, 2);
    });

    test('voucher/payments rỗng với vnpay lúc mới tạo', () {
      final booking = BookingModel.fromJson(_payload());

      expect(booking.voucher, isNull);
      expect(booking.payments, isEmpty);
    });

    test('đọc voucher khi đã thanh toán xong', () {
      final booking = BookingModel.fromJson(
        _payload(
          status: 'confirmed',
          voucher: {
            'voucherCode': 'V-123',
            'qrData': 'qr-payload',
            'usedAt': null,
          },
        ),
      );

      expect(booking.voucher?.voucherCode, 'V-123');
      expect(booking.voucher?.isUsed, isFalse);
    });
  });

  group('Booking.remainingHold', () {
    test('đếm ngược tới holdExpiresAt', () {
      final booking = BookingModel.fromJson(_payload());
      final now = DateTime.parse('2026-07-20T10:05:00.000Z');

      expect(booking.remainingHold(now), const Duration(minutes: 10));
      expect(booking.isHoldExpired(now), isFalse);
    });

    test('quá hạn thì trả Duration.zero chứ không trả số âm', () {
      final booking = BookingModel.fromJson(_payload());
      final now = DateTime.parse('2026-07-20T11:00:00.000Z');

      expect(booking.remainingHold(now), Duration.zero);
      expect(booking.isHoldExpired(now), isTrue);
    });

    test('booking tiền mặt không có hold', () {
      final booking = BookingModel.fromJson(
        _payload(status: 'confirmed', holdExpiresAt: null),
      );

      expect(booking.holdExpiresAt, isNull);
      expect(booking.remainingHold(DateTime.now()), isNull);
      expect(booking.isAwaitingPayment, isFalse);
    });
  });

  group('BookingModel.fromJson — dữ liệu hỏng', () {
    test('thiếu field bắt buộc thì ném ServerException, không ném TypeError', () {
      final broken = _payload()..remove('bookingCode');

      // TypeError sẽ không đi qua được đường Exception -> Failure và làm crash app.
      expect(
        () => BookingModel.fromJson(broken),
        throwsA(isA<ServerException>()),
      );
    });

    test('payments sai kiểu thì bỏ qua chứ không làm hỏng cả booking', () {
      final booking = BookingModel.fromJson(
        _payload(payments: ['không phải object', 42]),
      );

      expect(booking.payments, isEmpty);
      expect(booking.bookingCode, 'SS-XXXXXX');
    });
  });
}
