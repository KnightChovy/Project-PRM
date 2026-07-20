import 'package:equatable/equatable.dart';
import 'package:smart_stay_ai/core/utils/money.dart';
import 'booking_status.dart';

/// Một lượt đặt phòng trả về từ API (`POST /bookings`, `GET /bookings/{id}`).
///
/// Mọi field tiền là [Money] vì backend serialize Decimal thành chuỗi.
class Booking extends Equatable {
  final String id;
  final String bookingCode;
  final String customerId;
  final String hotelId;
  final String roomTypeId;

  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numNights;
  final int numGuests;

  final Money basePricePerNight;

  /// Tiền phòng thuần, CHƯA gồm thuế/phí.
  final Money subtotal;
  final Money discountAmount;
  final Money taxAmount;
  final Money feeAmount;

  /// = subtotal - discount + tax + fee. Do server tính, không tính lại ở client.
  final Money totalAmount;

  final BookingStatus status;
  final String source;
  final String? specialRequests;

  /// Hạn giữ chỗ với booking `pending`. `null` khi trả tiền mặt.
  /// Quá hạn là mất phòng — Presentation nên đếm ngược tới mốc này.
  final DateTime? holdExpiresAt;

  final DateTime createdAt;

  final BookingHotel? hotel;
  final BookingRoomType? roomType;

  /// Voucher check-in. `null` với vnpay/sepay lúc mới tạo, có sau khi trả xong.
  final BookingVoucher? voucher;

  final List<BookingPayment> payments;

  const Booking({
    required this.id,
    required this.bookingCode,
    required this.customerId,
    required this.hotelId,
    required this.roomTypeId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numNights,
    required this.numGuests,
    required this.basePricePerNight,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.feeAmount,
    required this.totalAmount,
    required this.status,
    required this.source,
    required this.createdAt,
    this.specialRequests,
    this.holdExpiresAt,
    this.hotel,
    this.roomType,
    this.voucher,
    this.payments = const [],
  });

  /// Còn phải thanh toán và đang trong thời gian giữ chỗ.
  bool get isAwaitingPayment => status == BookingStatus.pending;

  // ---- Getter dẫn xuất: phẳng hoá [hotel]/[roomType] cho tầng hiển thị ----
  // API trả hai object này lồng nhau và có thể null; gom về đây để widget khỏi
  // rải `?.` và `??` khắp nơi.

  String get hotelName => hotel?.name ?? '';

  /// Địa chỉ hiển thị: "123 Lê Lợi, Hồ Chí Minh".
  String get location {
    final parts = [hotel?.address, hotel?.city]
        .whereType<String>()
        .where((part) => part.isNotEmpty);
    return parts.join(', ');
  }

  String get roomName => roomType?.name ?? '';
  String get checkInTime => hotel?.checkInTime ?? '';
  String get checkOutTime => hotel?.checkOutTime ?? '';

  /// Voucher chỉ dùng được khi đã thanh toán xong và chưa bị quét.
  bool get hasUsableVoucher => voucher != null && !voucher!.isUsed;

  /// Thời gian còn lại trước khi mất chỗ. `null` nếu booking không có hold.
  ///
  /// Nhận [now] từ ngoài thay vì gọi `DateTime.now()` để entity không phụ thuộc
  /// đồng hồ hệ thống (dễ test).
  Duration? remainingHold(DateTime now) {
    final deadline = holdExpiresAt;
    if (deadline == null) return null;
    final left = deadline.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool isHoldExpired(DateTime now) => remainingHold(now) == Duration.zero;

  @override
  List<Object?> get props => [
        id,
        bookingCode,
        customerId,
        hotelId,
        roomTypeId,
        checkInDate,
        checkOutDate,
        numNights,
        numGuests,
        basePricePerNight,
        subtotal,
        discountAmount,
        taxAmount,
        feeAmount,
        totalAmount,
        status,
        source,
        specialRequests,
        holdExpiresAt,
        createdAt,
        hotel,
        roomType,
        voucher,
        payments,
      ];
}

/// Thông tin khách sạn kèm trong payload booking (không phải entity Hotel đầy đủ).
class BookingHotel extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String checkInTime;
  final String checkOutTime;

  const BookingHotel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.checkInTime,
    required this.checkOutTime,
  });

  @override
  List<Object?> get props =>
      [id, name, address, city, checkInTime, checkOutTime];
}

/// Thông tin loại phòng kèm trong payload booking.
class BookingRoomType extends Equatable {
  final String id;
  final String name;
  final String bedType;
  final String viewType;
  final int maxOccupancy;

  const BookingRoomType({
    required this.id,
    required this.name,
    required this.bedType,
    required this.viewType,
    required this.maxOccupancy,
  });

  @override
  List<Object?> get props => [id, name, bedType, viewType, maxOccupancy];
}

/// Voucher để lễ tân quét lúc check-in.
class BookingVoucher extends Equatable {
  final String voucherCode;
  final String qrData;
  final DateTime? usedAt;

  const BookingVoucher({
    required this.voucherCode,
    required this.qrData,
    this.usedAt,
  });

  bool get isUsed => usedAt != null;

  @override
  List<Object?> get props => [voucherCode, qrData, usedAt];
}

/// Một lần thanh toán gắn với booking.
///
/// Spec chưa mô tả schema của phần tử trong `payments[]`, nên mọi field đều
/// nullable và được parse phòng thủ — bổ sung khi backend chốt shape.
class BookingPayment extends Equatable {
  final String? id;
  final String? method;
  final String? status;
  final Money amount;
  final DateTime? paidAt;

  const BookingPayment({
    this.id,
    this.method,
    this.status,
    this.amount = Money.zero,
    this.paidAt,
  });

  @override
  List<Object?> get props => [id, method, status, amount, paidAt];
}
