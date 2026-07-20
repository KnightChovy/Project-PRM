import 'package:dio/dio.dart';
import 'package:smart_stay_ai/core/constants/api_constants.dart';
import 'package:smart_stay_ai/core/error/exceptions.dart';
import 'package:smart_stay_ai/core/network/api_error.dart';
import 'package:smart_stay_ai/core/network/dio_client.dart';
import '../../domain/entities/checkout.dart';
import '../../domain/entities/paginated.dart';
import '../../domain/entities/booking_status.dart';
import '../models/checkout_model.dart';
import '../models/paginated_model.dart';
import '../models/booking_model.dart';
import '../models/booking_status_mapper.dart';

/// Gọi API booking + payment. Lỗi thì NÉM Exception (không trả Either).
abstract interface class BookingRemoteDataSource {
  Future<BookingModel> create({
    required String hotelId,
    required String roomTypeId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numGuests,
    String? specialRequests,
    required PaymentMethod paymentMethod,
  });

  Future<Paginated<BookingModel>> getMine({
    BookingStatus? status,
    int? page,
    int? limit,
    String? sortBy,
  });

  Future<BookingModel> getById(String bookingId);

  Future<BookingModel> cancel({
    required String bookingId,
    required RefundDestination destination,
    String? reason,
  });

  Future<VnpayCheckoutModel> startVnpayCheckout(String bookingId);

  Future<SepayCheckoutModel> startSepayCheckout(String bookingId);

  Future<WalletPaymentResultModel> payWithWallet(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final DioClient client;
  const BookingRemoteDataSourceImpl(this.client);

  @override
  Future<BookingModel> create({
    required String hotelId,
    required String roomTypeId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numGuests,
    String? specialRequests,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final res = await client.dio.post(
        ApiConstants.bookings,
        // Tuyệt đối KHÔNG gửi field giá — Joi ở server reject (400).
        data: {
          'hotelId': hotelId,
          'roomTypeId': roomTypeId,
          'checkInDate': _toIsoDate(checkInDate),
          'checkOutDate': _toIsoDate(checkOutDate),
          'numGuests': numGuests,
          if (specialRequests != null && specialRequests.trim().isNotEmpty)
            'specialRequests': specialRequests.trim(),
          'paymentMethod': paymentMethodToApi(paymentMethod),
        },
      );
      return BookingModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Đặt phòng thất bại');
    }
  }

  @override
  Future<Paginated<BookingModel>> getMine({
    BookingStatus? status,
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    try {
      final res = await client.dio.get(
        ApiConstants.myBookings,
        queryParameters: {
          if (status != null) 'status': bookingStatusToApi(status),
          'page': ?page,
          'limit': ?limit,
          'sortBy': ?sortBy,
        },
      );
      return parsePaginated(res.data, BookingModel.fromJson);
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được danh sách đặt phòng');
    }
  }

  @override
  Future<BookingModel> getById(String bookingId) async {
    try {
      final res = await client.dio.get(ApiConstants.bookingById(bookingId));
      return BookingModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tải được chi tiết đặt phòng');
    }
  }

  @override
  Future<BookingModel> cancel({
    required String bookingId,
    required RefundDestination destination,
    String? reason,
  }) async {
    try {
      final res = await client.dio.patch(
        ApiConstants.cancelBooking(bookingId),
        data: {
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
          // `wallet` thì KHÔNG được gửi bankAccount (Joi forbidden -> 400).
          ...switch (destination) {
            WalletRefund() => {'refundMethod': 'wallet'},
            BankRefund(:final account) => {
                'refundMethod': 'bank',
                'bankAccount': {
                  'accountNumber': account.accountNumber,
                  'bankName': account.bankName,
                  'accountHolder': account.accountHolder,
                },
              },
          },
        },
      );
      return BookingModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Huỷ đặt phòng thất bại');
    }
  }

  @override
  Future<VnpayCheckoutModel> startVnpayCheckout(String bookingId) async {
    try {
      final res = await client.dio.post(ApiConstants.vnpayCheckout(bookingId));
      return VnpayCheckoutModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tạo được liên kết thanh toán');
    }
  }

  @override
  Future<SepayCheckoutModel> startSepayCheckout(String bookingId) async {
    try {
      final res = await client.dio.post(ApiConstants.sepayCheckout(bookingId));
      return SepayCheckoutModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Không tạo được mã QR chuyển khoản');
    }
  }

  @override
  Future<WalletPaymentResultModel> payWithWallet(String bookingId) async {
    try {
      final res = await client.dio.post(ApiConstants.walletPayment(bookingId));
      return WalletPaymentResultModel.fromJson(_asMap(res.data));
    } on DioException catch (e) {
      throwApiException(e, fallback: 'Thanh toán bằng ví thất bại');
    }
  }
}

/// `yyyy-MM-dd` — API chỉ nhận ngày, không nhận timestamp đầy đủ.
String _toIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  throw const ServerException(message: 'Dữ liệu trả về không hợp lệ');
}
