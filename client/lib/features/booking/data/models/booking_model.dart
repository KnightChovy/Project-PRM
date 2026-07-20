import 'package:smart_stay_ai/core/utils/money.dart';
import '../../domain/entities/booking.dart';
import 'json_reader.dart';
import 'booking_status_mapper.dart';

/// Ánh xạ payload booking của API sang entity [Booking].
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.bookingCode,
    required super.customerId,
    required super.hotelId,
    required super.roomTypeId,
    required super.checkInDate,
    required super.checkOutDate,
    required super.numNights,
    required super.numGuests,
    required super.basePricePerNight,
    required super.subtotal,
    required super.discountAmount,
    required super.taxAmount,
    required super.feeAmount,
    required super.totalAmount,
    required super.status,
    required super.source,
    required super.createdAt,
    super.specialRequests,
    super.holdExpiresAt,
    super.hotel,
    super.roomType,
    super.voucher,
    super.payments,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json.requireString('id'),
      bookingCode: json.requireString('bookingCode'),
      customerId: json.readString('customerId') ?? '',
      hotelId: json.readString('hotelId') ?? '',
      roomTypeId: json.readString('roomTypeId') ?? '',
      // Giữ nguyên UTC cho 2 field ngày: server gửi mốc 00:00:00Z mang ý nghĩa
      // "ngày", đổi sang local có thể lệch sang ngày khác ở múi giờ âm.
      checkInDate: json.requireUtcDate('checkInDate'),
      checkOutDate: json.requireUtcDate('checkOutDate'),
      numNights: json.readInt('numNights') ?? 0,
      numGuests: json.readInt('numGuests') ?? 0,
      basePricePerNight: Money.fromJson(json['basePricePerNight']),
      subtotal: Money.fromJson(json['subtotal']),
      discountAmount: Money.fromJson(json['discountAmount']),
      taxAmount: Money.fromJson(json['taxAmount']),
      feeAmount: Money.fromJson(json['feeAmount']),
      totalAmount: Money.fromJson(json['totalAmount']),
      status: bookingStatusFromApi(json['status']),
      source: json.readString('source') ?? '',
      specialRequests: json.readString('specialRequests'),
      // Mốc thời gian thật -> đổi sang giờ máy để đếm ngược cho đúng.
      holdExpiresAt: json.readLocalDate('holdExpiresAt'),
      createdAt: json.readLocalDate('createdAt') ?? DateTime.now(),
      hotel: json.readMap('hotel').mapOrNull(BookingHotelModel.fromJson),
      roomType:
          json.readMap('roomType').mapOrNull(BookingRoomTypeModel.fromJson),
      voucher:
          json.readMap('voucher').mapOrNull(BookingVoucherModel.fromJson),
      payments: json
          .readMapList('payments')
          .map(BookingPaymentModel.fromJson)
          .toList(growable: false),
    );
  }
}

class BookingHotelModel extends BookingHotel {
  const BookingHotelModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    required super.checkInTime,
    required super.checkOutTime,
  });

  factory BookingHotelModel.fromJson(Map<String, dynamic> json) {
    return BookingHotelModel(
      id: json.readString('id') ?? '',
      name: json.readString('name') ?? '',
      address: json.readString('address') ?? '',
      city: json.readString('city') ?? '',
      checkInTime: json.readString('checkInTime') ?? '',
      checkOutTime: json.readString('checkOutTime') ?? '',
    );
  }
}

class BookingRoomTypeModel extends BookingRoomType {
  const BookingRoomTypeModel({
    required super.id,
    required super.name,
    required super.bedType,
    required super.viewType,
    required super.maxOccupancy,
  });

  factory BookingRoomTypeModel.fromJson(Map<String, dynamic> json) {
    return BookingRoomTypeModel(
      id: json.readString('id') ?? '',
      name: json.readString('name') ?? '',
      bedType: json.readString('bedType') ?? '',
      viewType: json.readString('viewType') ?? '',
      maxOccupancy: json.readInt('maxOccupancy') ?? 0,
    );
  }
}

class BookingVoucherModel extends BookingVoucher {
  const BookingVoucherModel({
    required super.voucherCode,
    required super.qrData,
    super.usedAt,
  });

  factory BookingVoucherModel.fromJson(Map<String, dynamic> json) {
    return BookingVoucherModel(
      voucherCode: json.readString('voucherCode') ?? '',
      qrData: json.readString('qrData') ?? '',
      usedAt: json.readLocalDate('usedAt'),
    );
  }
}

/// Schema của phần tử `payments[]` chưa được spec mô tả — parse phòng thủ,
/// thiếu field thì bỏ qua chứ không làm hỏng cả booking.
class BookingPaymentModel extends BookingPayment {
  const BookingPaymentModel({
    super.id,
    super.method,
    super.status,
    super.amount,
    super.paidAt,
  });

  factory BookingPaymentModel.fromJson(Map<String, dynamic> json) {
    return BookingPaymentModel(
      id: json.readString('id'),
      method: json.readString('method') ?? json.readString('paymentMethod'),
      status: json.readString('status'),
      amount: Money.fromJson(json['amount']),
      paidAt: json.readLocalDate('paidAt'),
    );
  }
}
